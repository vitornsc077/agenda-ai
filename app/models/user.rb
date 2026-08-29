class User < ApplicationRecord
  include TenantScoped

  has_secure_password
  has_secure_token :api_token

  enum :role, {
    member: 0,
    admin: 1,
    owner: 2
  }, default: :member

  has_many :sessions, dependent: :destroy
  has_one :staff_member, dependent: :nullify

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :account_id, case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }
end
