module Public
  class BookingController < ApplicationController
    allow_unauthenticated_access
    layout "public"

    before_action :set_tenant_from_slug
    before_action :check_trial_status, only: %i[show availability create]

    def show
      @services = @account.services.active.ordered
      @staff_members = @account.staff_members.active
      @selected_service = @services.find_by(id: params[:service_id]) || @services.first
      @selected_staff = @staff_members.find_by(id: params[:staff_member_id])
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

      if @selected_service
        engine = AvailabilityEngine.new(account: @account)
        @available_slots = engine.available_slots(
          date: @selected_date,
          service: @selected_service,
          staff_member: @selected_staff
        )
      else
        @available_slots = []
      end
    end

    def availability
      @selected_service = @account.services.active.find_by(id: params[:service_id])
      @selected_staff = @account.staff_members.active.find_by(id: params[:staff_member_id])
      @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current

      if @selected_service
        engine = AvailabilityEngine.new(account: @account)
        @available_slots = engine.available_slots(
          date: @selected_date,
          service: @selected_service,
          staff_member: @selected_staff
        )
      else
        @available_slots = []
      end

      render partial: "public/booking/slots", locals: {
        slots: @available_slots,
        selected_date: @selected_date,
        selected_service: @selected_service,
        selected_staff: @selected_staff
      }
    end

    def create
      service = @account.services.find(params[:service_id])
      
      booking = BookingCreationService.new(account: @account).call(
        service_id: params[:service_id],
        staff_member_id: params[:staff_member_id].presence,
        starts_at: params[:starts_at],
        client_params: {
          name: params[:client_name],
          email: params[:client_email],
          phone: params[:client_phone]
        },
        notes: params[:notes]
      )

      redirect_to public_booking_confirmation_path(slug: @account.slug, token: booking.token), notice: "Agendamento realizado com sucesso!"
    rescue BookingCreationService::SlotUnavailableError => e
      redirect_to public_booking_path(slug: @account.slug, service_id: params[:service_id]), alert: e.message
    rescue ActiveRecord::RecordInvalid => e
      redirect_to public_booking_path(slug: @account.slug, service_id: params[:service_id]), alert: "Erro ao agendar: #{e.record.errors.full_messages.join(', ')}"
    end

    def confirmation
      @booking = @account.bookings.find_by!(token: params[:token])
      @service = @booking.service
      @staff = @booking.staff_member
      @client = @booking.client
    end

    def cancel
      @booking = @account.bookings.find_by!(token: params[:token])
      if @booking.update(status: :cancelled, cancellation_reason: params[:reason].presence || "Cancelado pelo cliente")
        NotificationDispatcher.new(@booking).dispatch_cancellation
        redirect_to public_booking_confirmation_path(slug: @account.slug, token: @booking.token), notice: "Seu agendamento foi cancelado com sucesso."
      else
        redirect_to public_booking_confirmation_path(slug: @account.slug, token: @booking.token), alert: "Não foi possível cancelar o agendamento."
      end
    end

    private

    def set_tenant_from_slug
      @account = Account.find_by!(slug: params[:slug])
      ActsAsTenant.current_tenant = @account
    rescue ActiveRecord::RecordNotFound
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end

    def check_trial_status
      trial_service = TrialStatusService.new(@account)
      unless trial_service.can_accept_bookings?
        render "public/booking/trial_expired", status: :payment_required
      end
    end
  end
end
