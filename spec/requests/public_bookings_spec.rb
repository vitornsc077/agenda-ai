require 'rails_helper'

RSpec.describe "Public Booking Flow", type: :request do
  let!(:account) { create(:account, name: "Barbearia Modelo", slug: "barbearia-modelo") }
  let!(:staff) { create(:staff_member, account: account, name: "Barbeiro Chefe") }
  let!(:service) { create(:service, account: account, name: "Corte Clássico", duration_minutes: 30, price_cents: 4000) }

  let(:next_monday) { Date.current.next_occurring(:monday) }
  let(:tz) { Time.find_zone("America/Sao_Paulo") }
  let(:slot_time) { tz.local(next_monday.year, next_monday.month, next_monday.day, 14, 0, 0) }

  before do
    staff.work_schedules.destroy_all
    create(:work_schedule, staff_member: staff, day_of_week: 1, start_time: "09:00", end_time: "18:00", enabled: true)
    service.staff_members << staff
  end

  describe "GET /:slug" do
    it "renders the public booking page successfully" do
      get public_booking_path(slug: account.slug)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Barbearia Modelo")
      expect(response.body).to include("Corte Clássico")
    end

    it "returns 404 for non-existent slug" do
      get "/slug-inexistente"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /:slug/availability" do
    it "renders the available slots turbo frame" do
      get public_booking_availability_path(slug: account.slug, service_id: service.id, staff_member_id: staff.id, date: next_monday.to_s)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("14:00")
    end
  end

  describe "POST /:slug/book and cancellation" do
    it "completes booking flow and allows cancellation with token" do
      # 1. Book
      post public_booking_create_path(slug: account.slug), params: {
        service_id: service.id,
        staff_member_id: staff.id,
        starts_at: slot_time.iso8601,
        client_name: "Ana Costa",
        client_email: "ana@exemplo.com",
        client_phone: "(11) 97777-6666"
      }

      booking = Booking.find_by(account: account)
      expect(booking).to be_present
      expect(response).to redirect_to(public_booking_confirmation_path(slug: account.slug, token: booking.token))

      # 2. View Confirmation
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ana Costa")
      expect(response.body).to include("Corte Clássico")

      # 3. Cancel with token
      patch public_booking_cancel_path(slug: account.slug, token: booking.token), params: { reason: "Imprevisto" }
      expect(response).to redirect_to(public_booking_confirmation_path(slug: account.slug, token: booking.token))

      booking.reload
      expect(booking.status).to eq("cancelled")
      expect(booking.cancellation_reason).to eq("Imprevisto")
    end
  end
end
