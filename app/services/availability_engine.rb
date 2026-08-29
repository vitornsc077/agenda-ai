class AvailabilityEngine
  Slot = Struct.new(:start_time, :end_time, :starts_at, :ends_at, :staff_member_id, keyword_init: true)

  def initialize(account:)
    @account = account
    @timezone = Time.find_zone(account.timezone) || Time.find_zone("America/Sao_Paulo")
  end

  def available_slots(date:, service:, staff_member: nil)
    target_date = date.is_a?(String) ? Date.parse(date) : date

    if staff_member.present?
      calculate_staff_slots(staff_member, target_date, service)
    else
      # If no specific staff selected, check all staff members assigned to this service (or all active staff)
      assigned_staff = service.staff_members.active
      assigned_staff = @account.staff_members.active if assigned_staff.empty?

      all_slots = []
      assigned_staff.each do |staff|
        slots = calculate_staff_slots(staff, target_date, service)
        all_slots.concat(slots)
      end

      # Group by start time to present unique time slots
      all_slots.uniq { |s| s.start_time }.sort_by(&:starts_at)
    end
  end

  def next_available_dates(service:, staff_member: nil, days_ahead: 30)
    start_date = Date.current
    end_date = start_date + days_ahead.days

    (start_date..end_date).select do |date|
      available_slots(date: date, service: service, staff_member: staff_member).any?
    end
  end

  private

  def calculate_staff_slots(staff, date, service)
    wday = date.wday
    schedule = staff.work_schedules.find_by(day_of_week: wday, enabled: true)
    return [] unless schedule

    # Check for full-day override block
    full_day_block = staff.schedule_overrides.find_by(
      override_date: date,
      override_type: :block,
      start_time: nil,
      end_time: nil
    )
    return [] if full_day_block

    # Working interval in local timezone
    start_hour, start_min = schedule.start_time.split(":").map(&:to_i)
    end_hour, end_min = schedule.end_time.split(":").map(&:to_i)

    day_start = @timezone.local(date.year, date.month, date.day, start_hour, start_min, 0)
    day_end = @timezone.local(date.year, date.month, date.day, end_hour, end_min, 0)

    # Fetch existing active bookings for this staff on this day
    existing_bookings = staff.bookings
                             .active_bookings
                             .where("starts_at < ? AND ends_at > ?", day_end.utc, day_start.utc)

    # Fetch partial day blocks for this date
    partial_blocks = staff.schedule_overrides.where(
      override_date: date,
      override_type: :block
    ).where.not(start_time: nil)

    duration = service.duration_minutes.minutes
    slots = []
    current_time = day_start

    while current_time + duration <= day_end
      slot_start = current_time
      slot_end = current_time + duration

      # Check if slot is in the past
      is_past = slot_start < Time.current + 10.minutes

      # Check overlap with existing bookings
      overlaps_booking = existing_bookings.any? do |b|
        slot_start.utc < b.ends_at && slot_end.utc > b.starts_at
      end

      # Check overlap with partial override blocks
      overlaps_override = partial_blocks.any? do |ov|
        ov_s_h, ov_s_m = ov.start_time.split(":").map(&:to_i)
        ov_e_h, ov_e_m = ov.end_time.split(":").map(&:to_i)
        ov_start = @timezone.local(date.year, date.month, date.day, ov_s_h, ov_s_m, 0)
        ov_end = @timezone.local(date.year, date.month, date.day, ov_e_h, ov_e_m, 0)
        slot_start < ov_end && slot_end > ov_start
      end

      unless is_past || overlaps_booking || overlaps_override
        slots << Slot.new(
          start_time: slot_start.strftime("%H:%M"),
          end_time: slot_end.strftime("%H:%M"),
          starts_at: slot_start,
          ends_at: slot_end,
          staff_member_id: staff.id
        )
      end

      # Advance in 30-minute intervals or service duration (whichever is standard)
      step = [30.minutes, duration].min
      current_time += step
    end

    slots
  end
end
