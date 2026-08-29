require 'rails_helper'

RSpec.describe "Admin Billing & Subscriptions", type: :request do
  let!(:account) { create(:account) }
  let!(:owner) { create(:user, account: account, role: :owner) }

  before do
    post session_path, params: { email: owner.email, password: owner.password }
  end

  describe "GET /admin/billing" do
    it "renders the plans and pricing page" do
      get admin_billing_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Plano Mensal")
      expect(response.body).to include("79,90")
      expect(response.body).to include("Plano Anual")
      expect(response.body).to include("549,00")
    end
  end

  describe "POST /admin/billing/checkout" do
    it "creates Stripe customer and redirects to Stripe Checkout session" do
      # Mock Stripe Customer creation & Checkout Session creation
      fake_customer = double("Stripe::Customer", id: "cus_test123")
      fake_session = double("Stripe::Checkout::Session", url: "https://checkout.stripe.com/test_session", id: "cs_test123")

      allow(Stripe::Customer).to receive(:create).and_return(fake_customer)
      allow(Stripe::Checkout::Session).to receive(:create).and_return(fake_session)

      post admin_billing_checkout_path, params: { interval: "year" }

      expect(response).to redirect_to("https://checkout.stripe.com/test_session")
      account.reload
      expect(account.stripe_customer_id).to eq("cus_test123")
    end
  end

  describe "POST /admin/billing/portal" do
    it "redirects to customer portal when customer exists" do
      account.update!(stripe_customer_id: "cus_existing123")
      fake_portal = double("Stripe::BillingPortal::Session", url: "https://billing.stripe.com/session123")
      allow(Stripe::BillingPortal::Session).to receive(:create).and_return(fake_portal)

      post admin_billing_portal_path
      expect(response).to redirect_to("https://billing.stripe.com/session123")
    end
  end

  describe "GET /admin/billing/success" do
    it "renders the success page" do
      get admin_billing_success_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Assinatura Ativada")
    end
  end

  describe "GET /admin/billing/cancel" do
    it "renders the cancel page" do
      get admin_billing_cancel_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Checkout não finalizado")
    end
  end
end
