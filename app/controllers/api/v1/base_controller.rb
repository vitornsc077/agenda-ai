module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_token!

      private

      def authenticate_api_token!
        token = extract_token_from_request
        @current_user = User.find_by(api_token: token) if token.present?

        if @current_user
          @current_account = @current_user.account
          ActsAsTenant.current_tenant = @current_account
          Current.account = @current_account
        else
          render json: {
            status: "error",
            error: "Unauthorized",
            message: "Token de API inválido ou não fornecido. Use o header 'Authorization: Bearer <seu_token>' ou 'X-API-Key: <seu_token>'."
          }, status: :unauthorized
        end
      end

      def extract_token_from_request
        header = request.headers["Authorization"]
        if header.present? && header.start_with?("Bearer ")
          header.split(" ").last.strip
        else
          request.headers["X-API-Key"].presence || params[:api_token].presence
        end
      end

      attr_reader :current_user, :current_account
    end
  end
end
