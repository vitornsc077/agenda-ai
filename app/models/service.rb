class Service < ApplicationRecord
  include TenantScoped

  has_many :service_staff_members, dependent: :destroy
  has_many :staff_members, through: :service_staff_members
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, name: :asc) }

  def price_reais
    return 0.0 unless price_cents
    price_cents / 100.0
  end

  def price_reais=(val)
    self.price_cents = (val.to_f * 100).round
  end

  def formatted_price
    return "Grátis" if price_cents.blank? || price_cents.zero?
    "R$ #{'%.2f' % price_reais}".gsub('.', ',')
  end
end
