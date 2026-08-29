class ServiceStaffMember < ApplicationRecord
  belongs_to :service
  belongs_to :staff_member

  validates :service_id, uniqueness: { scope: :staff_member_id }
end
