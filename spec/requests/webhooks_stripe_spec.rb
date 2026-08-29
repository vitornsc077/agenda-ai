require 'rails_helper'

RSpec.describe "Stripe Webhooks", type: :request do
  let!(:account) { create(:account, stripe_customer_id: "cus_webhook_test", plan: :trial) }

  describe "POST /webhooks/stripe" do
    it "handles checkout.session.completed and activates subscription" do
      payload = {
        id: "evt_123",
        type: "checkout.session.completed",
        data: {
          object: {
            id: "cs_123",
            customer: "cus_webhook_test",
            subscription: "sub_123",
            metadata: {
              account_id: account.id,
              interval: "year"
            }
          }
        }
      }.to_json

      post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:ok)
      account.reload
      expect(account.subscription_status).to eq("active")
      expect(account.subscription_interval).to eq("year")
      expect(account.stripe_subscription_id).to eq("sub_123")
      expect(account.plan).to eq("professional")
      expect(account.active_subscription?).to be true
    end

    it "handles customer.subscription.deleted" do
      account.update!(stripe_subscription_id: "sub_cancel_test", subscription_status: "active")

      payload = {
        id: "evt_456",
        type: "customer.subscription.deleted",
        data: {
          object: {
            id: "sub_cancel_test",
            customer: "cus_webhook_test"
          }
        }
      }.to_json

      post "/webhooks/stripe", params: payload, headers: { "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:ok)
      account.reload
      expect(account.subscription_status).to eq("canceled")
      expect(account.active_subscription?).to be false
    end
  end
end
