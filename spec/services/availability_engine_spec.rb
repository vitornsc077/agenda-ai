require 'rails_helper'

RSpec.describe AvailabilityEngine do
  let(:account) { create(:account, timezone: "America/Sao_Paulo") }
  let(:staff) { create(:staff_member, account: account) }
  let(:service_30m) { create(:service, account: account, duration_minutes: 30) }
  let(:service_60m) { create(:service, account: account, duration_minutes: 60) }
  let(:engine) { described_class.new(account: account) }

  # Test target date: Next Monday
  let(:next_monday) { Date.current.next_occurring(:monday) }

  before do
    staff.work_schedules.destroy_all
    create(:work_schedule, staff_member: staff, day_of_week: 1, start_time: "09:00", end_time: "12:00", enabled: true)
  end

  describe "#available_slots" do
    it "returns correct 30-minute slots when there are no bookings" do
      slots = engine.available_slots(date: next_monday, service: service_30m, staff_member: staff)
      start_times = slots.map(&:start_time)

      expect(start_times).to eq(["09:00", "09:30", "10:00", "10:30", "11:00", "11:30"])
    end

    it "returns correct 60-minute slots" do
      slots = engine.available_slots(date: next_monday, service: service_60m, staff_member: staff)
      start_times = slots.map(&:start_time)

      expect(start_times).to eq(["09:00", "09:30", "10:00", "10:30", "11:00"])
    end

    it "removes slots occupied by existing confirmed bookings" do
      client = create(:client, account: account)
      tz = Time.find_zone("America/Sao_Paulo")
      booking_start = tz.local(next_monday.year, next_monday.month, next_monday.day, 10, 0, 0)

      create(:booking,
        account: account,
        staff_member: staff,
        service: service_30m,
        client: client,
        starts_at: booking_start,
        ends_at: booking_start + 30.minutes,
        status: :confirmed
      )

      slots = engine.available_slots(date: next_monday, service: service_30m, staff_member: staff)
      start_times = slots.map(&:start_time)

      expect(start_times).not_to include("10:00")
      expect(start_times).to include("09:30", "10:30")
    end

    it "returns empty array when day has a full-day block override" do
      create(:schedule_override, staff_member: staff, override_date: next_monday, override_type: :block, start_time: nil, end_time: nil)

      slots = engine.available_slots(date: next_monday, service: service_30m, staff_member: staff)
      expect(slots).to be_empty
    end

    it "removes slots overlapping with partial block override" do
      create(:schedule_override, staff_member: staff, override_date: next_monday, override_type: :block, start_time: "09:00", end_time: "10:00")

      slots = engine.available_slots(date: next_monday, service: service_30m, staff_member: staff)
      start_times = slots.map(&:start_time)

      expect(start_times).not_to include("09:00", "09:30")
      expect(start_times).to include("10:00", "10:30", "11:00", "11:30")
    end

    it "returns empty if day is disabled or outside working days" do
      sunday = Date.current.next_occurring(:sunday)
      slots = engine.available_slots(date: sunday, service: service_30m, staff_member: staff)
      expect(slots).to be_empty
    end
  end

  describe "#next_available_dates" do
    it "finds upcoming dates with availability" do
      dates = engine.next_available_dates(service: service_30m, staff_member: staff, days_ahead: 14)
      expect(dates).to include(next_monday)
    end
  end
end
