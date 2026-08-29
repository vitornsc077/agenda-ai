class BookingCreationService
  class SlotUnavailableError < StandardError; end

  def initialize(account:)
    @account = account
  end

  def call(service_id:, staff_member_id:, starts_at:, client_params:, notes: nil)
    service = @account.services.find(service_id)
    parsed_starts_at = starts_at.is_a?(String) ? Time.zone.parse(starts_at) : starts_at
    calculated_ends_at = parsed_starts_at + service.duration_minutes.minutes

    staff_member = if staff_member_id.present?
                     @account.staff_members.find(staff_member_id)
                   else
                     select_available_staff(service, parsed_starts_at, calculated_ends_at)
                   end

    raise SlotUnavailableError, "Nenhum profissional disponível para o horário selecionado." unless staff_member

    ActiveRecord::Base.transaction do
      # Check again inside transaction to prevent race conditions / double booking
      overlapping_count = Booking.where(staff_member_id: staff_member.id)
                                 .active_bookings
                                 .where("starts_at < ? AND ends_at > ?", calculated_ends_at.utc, parsed_starts_at.utc)
                                 .lock
                                 .count

      if overlapping_count > 0
        raise SlotUnavailableError, "Este horário acabou de ser reservado por outro cliente. Por favor, selecione outro horário."
      end

      # Find or create client
      client = @account.clients.find_or_initialize_by(email: client_params[:email].to_s.strip.downcase)
      client.name = client_params[:name] if client_params[:name].present?
      client.phone = client_params[:phone] if client_params[:phone].present?
      client.save!

      # Create booking
      booking = @account.bookings.create!(
        service: service,
        staff_member: staff_member,
        client: client,
        starts_at: parsed_starts_at,
        ends_at: calculated_ends_at,
        status: :confirmed,
        price_cents: service.price_cents,
        currency: service.currency,
        notes: notes
      )

      # Dispatch confirmation notifications
      NotificationDispatcher.new(booking).dispatch_confirmation

      booking
    end
  end

  private

  def select_available_staff(service, starts_at, ends_at)
    candidates = service.staff_members.active
    candidates = @account.staff_members.active if candidates.empty?

    candidates.find do |staff|
      # Check work schedule for this day
      wday = starts_at.wday
      schedule = staff.work_schedules.find_by(day_of_week: wday, enabled: true)
      next false unless schedule

      # Check no overlapping booking
      no_overlap = !staff.bookings
                         .active_bookings
                         .where("starts_at < ? AND ends_at > ?", ends_at.utc, starts_at.utc)
                         .exists?

      # Check no block override
      no_override = !staff.schedule_overrides
                          .where(override_date: starts_at.to_date, override_type: :block)
                          .exists?

      no_overlap && no_override
    end
  end
end
