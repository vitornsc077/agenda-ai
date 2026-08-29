require 'rails_helper'

RSpec.describe "Admin Services Management", type: :request do
  let!(:account) { create(:account) }
  let!(:owner) { create(:user, account: account, role: :owner) }
  let!(:service) { create(:service, account: account, name: "Massagem Relaxante") }

  before do
    # Sign in user
    post session_path, params: { email: owner.email, password: owner.password }
  end

  describe "GET /admin/services" do
    it "renders the services list" do
      get admin_services_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Massagem Relaxante")
    end
  end

  describe "POST /admin/services" do
    it "creates a new service" do
      expect {
        post admin_services_path, params: {
          service: {
            name: "Drenagem Linfática",
            duration_minutes: 60,
            price_reais: 120.00,
            active: true
          }
        }
      }.to change(Service, :count).by(1)

      expect(response).to redirect_to(admin_services_path)
    end
  end

  describe "PATCH /admin/services/:id/toggle_active" do
    it "toggles the service active status" do
      expect(service.active?).to be true
      patch toggle_active_admin_service_path(service)
      service.reload
      expect(service.active?).to be false
    end
  end
end
