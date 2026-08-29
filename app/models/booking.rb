class Booking < ApplicationRecord
  include TenantScoped

  belongs_to :service
  belongs_to :staff_member
  belongs_to :client, counter_cache: true
  has_many :notifications, dependent: :destroy

  enum :status, {
    pending: 0,
    confirmed: 1,
    completed: 2,
    cancelled: 3,
    no_show: 4
  }, default: :confirmed

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :token, presence: true, uniqueness: true
  validate :ends_at_after_starts_at

  before_validation :generate_token, if: -> { token.blank? }

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(starts_at: :asc) }
  scope :past, -> { where("starts_at < ?", Time.current).order(starts_at: :desc) }
  scope :for_date, ->(date) { where(starts_at: date.beginning_of_day..date.end_of_day) }
  scope :active_bookings, -> { where.not(status: :cancelled) }

  def duration_minutes
    return 0 unless starts_at && ends_at
    ((ends_at - starts_at) / 60).to_i
  end

  def formatted_price
    return "Grátis" if price_cents.blank? || price_cents.zero?
    "R$ #{'%.2f' % (price_cents / 100.0)}".gsub('.', ',')
  end

  def cancel!(reason = nil)
    update!(status: :cancelled, cancellation_reason: reason)
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(24)
  end

  def ends_at_after_starts_at
    return if starts_at.blank? || ends_at.blank?
    if ends_at <= starts_at
      errors.add(:ends_at, "deve ser posterior ao horário de início")
    end
  end
end
