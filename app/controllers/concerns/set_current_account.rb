module SetCurrentAccount
  extend ActiveSupport::Concern

  included do
    before_action :set_current_account
  end

  private

  def set_current_account
    if current_user&.account
      ActsAsTenant.current_tenant = current_user.account
      Current.account = current_user.account
    end
  end
end
