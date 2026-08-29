require 'rails_helper'

RSpec.describe BookingCreationService do
  let(:account) { create(:account, timezone: "America/Sao_Paulo") }
  let(:staff) { create(:staff_member, account: account) }
  let(:service) { create(:service, account: account, duration_minutes: 30, price_cents: 5000) }
  let(:service_creator) { described_class.new(account: account) }

  let(:next_monday) { Date.current.next_occurring(:monday) }
  let(:tz) { Time.find_zone("America/Sao_Paulo") }
  let(:slot_time) { tz.local(next_monday.year, next_monday.month, next_monday.day, 10, 0, 0) }

  before do
    staff.work_schedules.destroy_all
    create(:work_schedule, staff_member: staff, day_of_week: 1, start_time: "09:00", end_time: "18:00", enabled: true)
  end

  describe "#call" do
    it "successfully creates booking and client" do
      booking = service_creator.call(
        service_id: service.id,
        staff_member_id: staff.id,
        starts_at: slot_time,
        client_params: {
          name: "Maria Santos",
          email: "maria@exemplo.com",
          phone: "(11) 98888-7777"
        },
        notes: "Primeira visita"
      )

      expect(booking).to be_persisted
      expect(booking.client.name).to eq("Maria Santos")
      expect(booking.client.email).to eq("maria@exemplo.com")
      expect(booking.service).to eq(service)
      expect(booking.staff_member).to eq(staff)
      expect(booking.starts_at).to eq(slot_time)
      expect(booking.ends_at).to eq(slot_time + 30.minutes)
      expect(booking.status).to eq("confirmed")
      expect(booking.token).to be_present
    end

    it "raises SlotUnavailableError when attempting double booking on the same time" do
      # Create initial booking
      service_creator.call(
        service_id: service.id,
        staff_member_id: staff.id,
        starts_at: slot_time,
        client_params: { name: "Cliente 1", email: "c1@exemplo.com" }
      )

      # Attempt concurrent booking for same slot
      expect {
        service_creator.call(
          service_id: service.id,
          staff_member_id: staff.id,
          starts_at: slot_time,
          client_params: { name: "Cliente 2", email: "c2@exemplo.com" }
        )
      }.to raise_error(BookingCreationService::SlotUnavailableError)
    end
  end
end
