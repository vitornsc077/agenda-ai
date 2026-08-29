module TenantScoped
  extend ActiveSupport::Concern

  included do
    acts_as_tenant(:account)
    belongs_to :account
  end
end
