class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    redirect_to admin_root_path if authenticated?
    @account = Account.new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @account = Account.create!(
        name: params[:account_name].presence || "#{params[:name]}'s Business",
        timezone: params[:timezone].presence || "America/Sao_Paulo",
        plan: :trial
      )

      ActsAsTenant.with_tenant(@account) do
        @user = @account.users.create!(
          name: params[:name],
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          role: :owner
        )

        # Create initial staff member profile for the owner
        @staff_member = @account.staff_members.create!(
          user: @user,
          name: @user.name,
          email: @user.email
        )

        # Create default work schedule (Segunda a Sexta, 09:00 - 18:00)
        (1..5).each do |day|
          @staff_member.work_schedules.create!(
            day_of_week: day,
            start_time: "09:00",
            end_time: "18:00",
            enabled: true
          )
        end
      end

      start_new_session_for @user
      redirect_to admin_root_path, notice: "Conta criada com sucesso! Aproveite seus 14 dias de teste."
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Não foi possível criar sua conta: #{e.record.errors.full_messages.join(', ')}"
    render :new, status: :unprocessable_entity
  end
end
