class Account < ApplicationRecord
  enum :plan, {
    trial: 0,
    starter: 1,
    professional: 2,
    business: 3,
    enterprise: 4
  }, default: :trial

  has_many :users, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :staff_members, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "deve conter apenas letras minúsculas, números e hífens" }
  validates :timezone, presence: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_create :set_trial_period, if: -> { trial_ends_at.blank? && trial? }

  def subscribed?
    subscription_status == "active"
  end

  def active_subscription?
    subscribed?
  end

  def canceled?
    subscription_status == "canceled"
  end

  def on_trial?
    trial? && !active_subscription?
  end

  def trial_expired?
    return false if active_subscription?
    trial? && trial_ends_at.present? && trial_ends_at < Time.current
  end

  def has_valid_access?
    return true if active_subscription?
    trial? && !trial_expired?
  end

  def access_blocked?
    !has_valid_access?
  end

  def trial_days_left
    return 0 if active_subscription?
    return 0 unless trial?
    return 0 if trial_ends_at.blank? || trial_ends_at < Time.current
    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  def plan_name
    if active_subscription?
      subscription_interval == "year" ? "Plano Anual" : "Plano Mensal"
    elsif access_blocked?
      "Plano Expirado"
    else
      "Período de Teste"
    end
  end

  private

  def generate_slug
    base = name.to_s.parameterize
    base = "conta-#{SecureRandom.hex(3)}" if base.blank?
    candidate = base
    counter = 1
    while Account.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end

  def set_trial_period
    self.trial_ends_at = 14.days.from_now
  end
end
