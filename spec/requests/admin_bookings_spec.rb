require 'rails_helper'

RSpec.describe "Admin Bookings & Calendar", type: :request do
  let!(:account) { create(:account) }
  let!(:owner) { create(:user, account: account, role: :owner) }
  let!(:staff) { create(:staff_member, account: account) }
  let!(:service) { create(:service, account: account) }
  let!(:client) { create(:client, account: account) }
  let!(:booking) { create(:booking, account: account, staff_member: staff, service: service, client: client, status: :pending) }

  before do
    post session_path, params: { email: owner.email, password: owner.password }
  end

  describe "GET /admin/bookings" do
    it "renders the bookings list" do
      get admin_bookings_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(client.name)
    end
  end

  describe "PATCH /admin/bookings/:id/confirm and complete" do
    it "updates booking status" do
      patch confirm_admin_booking_path(booking)
      booking.reload
      expect(booking.confirmed?).to be true

      patch complete_admin_booking_path(booking)
      booking.reload
      expect(booking.completed?).to be true
    end
  end

  describe "GET /admin/calendar" do
    it "renders the week calendar" do
      get admin_calendar_path(view: "week")
      expect(response).to have_http_status(:ok)
    end

    it "renders the day calendar" do
      get admin_calendar_path(view: "day", date: Date.current.to_s)
      expect(response).to have_http_status(:ok)
    end

    it "renders the month calendar" do
      get admin_calendar_path(view: "month")
      expect(response).to have_http_status(:ok)
    end
  end
end
