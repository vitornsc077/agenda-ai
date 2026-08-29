require "rails_helper"

RSpec.describe "Api::V1::Services", type: :request do
  let!(:account) { Account.create!(name: "Barbearia Teste", slug: "barbearia-teste-api", timezone: "America/Sao_Paulo", plan: :trial) }
  let!(:user) { account.users.create!(name: "Carlos", email: "carlos_api@teste.com", password: "password123", role: :owner) }
  let!(:staff) { account.staff_members.create!(name: "Lucas", email: "lucas_api@teste.com", user: user, active: true) }

  before do
    user.regenerate_api_token if user.api_token.blank?
  end

  describe "POST /api/v1/services" do
    context "without authentication token" do
      it "returns 401 unauthorized" do
        post "/api/v1/services", params: { name: "Corte Barba" }, as: :json
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
      end
    end

    context "with valid Bearer token" do
      it "creates a new service and associates active staff" do
        expect {
          post "/api/v1/services",
               params: {
                 name: "Barboterapia Especial",
                 description: "Com óleos nobres",
                 duration_minutes: 45,
                 price_reais: 65.50,
                 active: true
               },
               headers: { "Authorization" => "Bearer #{user.api_token}" },
               as: :json
        }.to change(Service, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["service"]["name"]).to eq("Barboterapia Especial")
        expect(json["service"]["duration_minutes"]).to eq(45)
        expect(json["service"]["price_cents"]).to eq(6550)
        expect(json["service"]["price_formatted"]).to eq("R$ 65,50")
        expect(json["public_booking_url"]).to include("barbearia-teste-api")
      end
    end

    context "with valid X-API-Key header" do
      it "authenticates and creates the service" do
        post "/api/v1/services",
             params: { name: "Corte Simples", duration_minutes: 20, price_reais: 30.0 },
             headers: { "X-API-Key" => user.api_token },
             as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["service"]["name"]).to eq("Corte Simples")
      end
    end
  end

  describe "GET /api/v1/services" do
    it "lists all services for the authenticated account" do
      account.services.create!(name: "S1", duration_minutes: 30, price_cents: 3000, active: true)

      get "/api/v1/services", headers: { "Authorization" => "Bearer #{user.api_token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["services"].length).to eq(1)
      expect(json["services"].first["name"]).to eq("S1")
    end
  end
end
