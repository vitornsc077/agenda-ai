class SendReminderJob < ApplicationJob
  queue_as :default

  def perform
    tomorrow_start = 1.day.from_now.beginning_of_day
    tomorrow_end = 1.day.from_now.end_of_day

    bookings = Booking.confirmed
                      .where(starts_at: tomorrow_start..tomorrow_end)
                      .where.not(id: Notification.where(notification_type: :reminder_24h).select(:booking_id))

    bookings.find_each do |booking|
      NotificationDispatcher.new(booking).dispatch_reminder_24h
    end
  end
end
