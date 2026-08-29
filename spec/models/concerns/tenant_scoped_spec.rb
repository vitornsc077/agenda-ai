require 'rails_helper'

RSpec.describe "Multi-Tenant Data Isolation", type: :model do
  let!(:account_a) { create(:account, name: "Tenant A", slug: "tenant-a") }
  let!(:account_b) { create(:account, name: "Tenant B", slug: "tenant-b") }

  let!(:service_a) { create(:service, account: account_a, name: "Corte A") }
  let!(:service_b) { create(:service, account: account_b, name: "Corte B") }

  let!(:client_a) { create(:client, account: account_a, name: "Cliente A") }
  let!(:client_b) { create(:client, account: account_b, name: "Cliente B") }

  it "never returns records from other tenants when scoped to Tenant A" do
    ActsAsTenant.with_tenant(account_a) do
      expect(Service.all).to include(service_a)
      expect(Service.all).not_to include(service_b)

      expect(Client.all).to include(client_a)
      expect(Client.all).not_to include(client_b)
    end
  end

  it "never returns records from other tenants when scoped to Tenant B" do
    ActsAsTenant.with_tenant(account_b) do
      expect(Service.all).to include(service_b)
      expect(Service.all).not_to include(service_a)

      expect(Client.all).to include(client_b)
      expect(Client.all).not_to include(client_a)
    end
  end
end
