class Notification < ApplicationRecord
  belongs_to :booking

  enum :notification_type, {
    confirmation: 0,
    reminder_24h: 1,
    cancellation: 2
  }

  enum :channel, {
    email: 0,
    whatsapp: 1
  }, default: :email

  enum :status, {
    pending: 0,
    sent: 1,
    failed: 2
  }, default: :pending

  scope :pending_to_send, -> { where(status: :pending).where("scheduled_for IS NULL OR scheduled_for <= ?", Time.current) }
end
