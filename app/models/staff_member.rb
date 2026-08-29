class StaffMember < ApplicationRecord
  include TenantScoped

  belongs_to :user, optional: true
  has_many :service_staff_members, dependent: :destroy
  has_many :services, through: :service_staff_members
  has_many :work_schedules, dependent: :destroy
  has_many :schedule_overrides, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :account_id, case_sensitive: false }

  scope :active, -> { where(active: true) }

  after_create :create_default_schedule

  private

  def create_default_schedule
    return if work_schedules.any?
    (1..5).each do |day|
      work_schedules.create(
        day_of_week: day,
        start_time: "09:00",
        end_time: "18:00",
        enabled: true
      )
    end
  end
end
