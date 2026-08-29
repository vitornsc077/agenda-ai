module Admin
  class ApiTokensController < BaseController
    def show
      @user = current_user
      @user.regenerate_api_token if @user.api_token.blank?
    end

    def update
      current_user.regenerate_api_token
      redirect_to admin_api_token_path, notice: "Novo Token de API gerado com sucesso! O token anterior foi invalidado."
    end
  end
end
