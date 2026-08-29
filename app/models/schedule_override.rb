class ScheduleOverride < ApplicationRecord
  belongs_to :staff_member

  enum :override_type, {
    block: 0,
    available: 1
  }, default: :block

  validates :override_date, presence: true
  validate :end_time_after_start_time, if: -> { start_time.present? && end_time.present? }

  def full_day?
    start_time.blank? && end_time.blank?
  end

  private

  def end_time_after_start_time
    if start_time >= end_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end
end
