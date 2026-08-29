require 'rails_helper'

RSpec.describe "Trial and Subscription Access Control", type: :request do
  let!(:account) { create(:account, slug: "teste-bloqueio", trial_ends_at: 14.days.from_now, plan: :trial) }

  context "quando o período de teste está ativo" do
    it "permite acesso público ao agendamento" do
      get "/teste-bloqueio"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(account.name)
    end
  end

  context "quando o período de teste expira e não há assinatura ativa" do
    before do
      account.update!(trial_ends_at: 1.day.ago, subscription_status: "trialing")
    end

    it "bloqueia a página pública com HTTP 402 e exibe tela de aviso" do
      get "/teste-bloqueio"
      expect(response).to have_http_status(:payment_required)
      expect(response.body).to include("Agenda Temporariamente Indisponível")
      expect(response.body).to include("está pausada no momento")
    end
  end

  context "quando o plano foi assinado no Stripe" do
    before do
      account.update!(
        trial_ends_at: 1.day.ago,
        subscription_status: "active",
        subscription_interval: "month",
        plan: :professional
      )
    end

    it "desbloqueia o agendamento imediatamente mesmo com trial vencido" do
      get "/teste-bloqueio"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(account.name)
    end
  end
end
