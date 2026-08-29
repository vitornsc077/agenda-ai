class Client < ApplicationRecord
  include TenantScoped

  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :account_id, case_sensitive: false }

  normalizes :email, with: ->(e) { e.strip.downcase }
end
