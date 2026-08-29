class PasswordsController < ApplicationController
  allow_unauthenticated_access

  def new
  end

  def create
    # Placeholder for password reset email flow
    redirect_to new_session_path, notice: "Se o e-mail existir em nossa base, instruções foram enviadas."
  end
end
