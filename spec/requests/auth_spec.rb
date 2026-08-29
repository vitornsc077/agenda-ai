require 'rails_helper'

RSpec.describe "Authentication & Registration", type: :request do
  describe "POST /registration" do
    it "creates new account, owner user and signs in" do
      expect {
        post registration_path, params: {
          account_name: "Estúdio Beleza",
          name: "Roberta Lima",
          email: "roberta@estudio.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }.to change(Account, :count).by(1).and change(User, :count).by(1)

      account = Account.last
      expect(account.name).to eq("Estúdio Beleza")
      expect(account.slug).to eq("estudio-beleza")
      expect(account.users.first.email).to eq("roberta@estudio.com")
      expect(account.users.first.owner?).to be true

      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "POST /session (Login)" do
    let!(:account) { create(:account) }
    let!(:user) { create(:user, account: account, email: "login@teste.com", password: "password123") }

    it "logs in with correct credentials" do
      post session_path, params: { email: "login@teste.com", password: "password123" }
      expect(response).to redirect_to(admin_root_path)
    end

    it "rejects invalid credentials" do
      post session_path, params: { email: "login@teste.com", password: "wrongpassword" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
