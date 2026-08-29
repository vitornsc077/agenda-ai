module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: %i[show confirm cancel complete no_show]

    def index
      @bookings = current_account.bookings.includes(:service, :staff_member, :client)
      
      @bookings = @bookings.where(status: params[:status]) if params[:status].present?
      @bookings = @bookings.where(staff_member_id: params[:staff_member_id]) if params[:staff_member_id].present?
      @bookings = @bookings.where(service_id: params[:service_id]) if params[:service_id].present?
      
      if params[:date].present?
        target_date = Date.parse(params[:date])
        @bookings = @bookings.for_date(target_date)
      end

      @bookings = @bookings.order(starts_at: :desc).page(params[:page]) if @bookings.respond_to?(:page)
      @bookings = @bookings.order(starts_at: :desc).limit(50) unless @bookings.respond_to?(:page)
      
      @staff_members = current_account.staff_members.active
      @services = current_account.services.active
    end

    def show
    end

    def new
      @booking = current_account.bookings.new(starts_at: Time.current.change(min: 0) + 1.hour)
      @services = current_account.services.active
      @staff_members = current_account.staff_members.active
    end

    def create
      service = current_account.services.find(params[:service_id])
      starts_at = Time.zone.parse(params[:starts_at])

      @booking = BookingCreationService.new(account: current_account).call(
        service_id: params[:service_id],
        staff_member_id: params[:staff_member_id],
        starts_at: starts_at,
        client_params: {
          name: params[:client_name],
          email: params[:client_email],
          phone: params[:client_phone]
        },
        notes: params[:notes]
      )

      redirect_to admin_booking_path(@booking), notice: "Agendamento manual criado com sucesso!"
    rescue BookingCreationService::SlotUnavailableError => e
      flash.now[:alert] = e.message
      @services = current_account.services.active
      @staff_members = current_account.staff_members.active
      @booking = current_account.bookings.new
      render :new, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = "Erro ao criar agendamento: #{e.record.errors.full_messages.join(', ')}"
      @services = current_account.services.active
      @staff_members = current_account.staff_members.active
      @booking = current_account.bookings.new
      render :new, status: :unprocessable_entity
    end

    def confirm
      @booking.update!(status: :confirmed)
      redirect_back fallback_location: admin_bookings_path, notice: "Agendamento confirmado!"
    end

    def cancel
      @booking.cancel!(params[:cancellation_reason].presence || "Cancelado pelo administrador")
      NotificationDispatcher.new(@booking).dispatch_cancellation
      redirect_back fallback_location: admin_bookings_path, notice: "Agendamento cancelado com sucesso."
    end

    def complete
      @booking.update!(status: :completed)
      redirect_back fallback_location: admin_bookings_path, notice: "Agendamento marcado como concluído!"
    end

    def no_show
      @booking.update!(status: :no_show)
      redirect_back fallback_location: admin_bookings_path, notice: "Marcado como não compareceu (No-Show)."
    end

    private

    def set_booking
      @booking = current_account.bookings.find(params[:id])
    end
  end
end
