module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :ensure_admin_or_owner

    private

    def ensure_admin_or_owner
      unless current_user&.admin? || current_user&.owner?
        terminate_session
        redirect_to new_session_path, alert: "Você não tem permissão para acessar esta área."
      end
    end
  end
end
