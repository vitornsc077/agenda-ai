class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    if authenticated?
      if current_user&.admin? || current_user&.owner?
        redirect_to admin_root_path
      elsif current_account&.slug.present?
        redirect_to public_booking_path(slug: current_account.slug)
      end
    end
  end

  def create
    user = User.where(email: params[:email].to_s.strip.downcase).first
    if user&.authenticate(params[:password])
      start_new_session_for user
      redirect_to session.delete(:return_to_after_authenticating) || admin_root_path, notice: "Bem-vindo de volta, #{user.name}!"
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Você saiu com sucesso."
  end
end
