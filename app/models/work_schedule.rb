class WorkSchedule < ApplicationRecord
  belongs_to :staff_member

  DAYS = {
    0 => "Domingo",
    1 => "Segunda-feira",
    2 => "Terça-feira",
    3 => "Quarta-feira",
    4 => "Quinta-feira",
    5 => "Sexta-feira",
    6 => "Sábado"
  }.freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  def day_name
    DAYS[day_of_week]
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    if start_time >= end_time
      errors.add(:end_time, "deve ser posterior ao horário de início")
    end
  end
end
