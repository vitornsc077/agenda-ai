class NotificationDispatcher
  def initialize(booking)
    @booking = booking
    @account = booking.account
  end

  def dispatch_confirmation
    notification = @booking.notifications.create!(
      notification_type: :confirmation,
      channel: :email,
      status: :pending
    )

    begin
      BookingMailer.confirmation_client(@booking).deliver_later
      BookingMailer.confirmation_staff(@booking).deliver_later
      notification.update!(status: :sent, sent_at: Time.current)
    rescue => e
      notification.update!(status: :failed)
      Rails.logger.error("Failed to dispatch confirmation email: #{e.message}")
    end
  end

  def dispatch_reminder_24h
    notification = @booking.notifications.create!(
      notification_type: :reminder_24h,
      channel: :email,
      status: :pending,
      scheduled_for: @booking.starts_at - 24.hours
    )

    begin
      BookingMailer.reminder_24h(@booking).deliver_later
      notification.update!(status: :sent, sent_at: Time.current)
    rescue => e
      notification.update!(status: :failed)
      Rails.logger.error("Failed to dispatch reminder email: #{e.message}")
    end
  end

  def dispatch_cancellation
    notification = @booking.notifications.create!(
      notification_type: :cancellation,
      channel: :email,
      status: :pending
    )

    begin
      BookingMailer.cancellation_notice(@booking).deliver_later
      notification.update!(status: :sent, sent_at: Time.current)
    rescue => e
      notification.update!(status: :failed)
      Rails.logger.error("Failed to dispatch cancellation email: #{e.message}")
    end
  end
end
