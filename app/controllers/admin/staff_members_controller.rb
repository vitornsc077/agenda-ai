module Admin
  class StaffMembersController < BaseController
    before_action :set_staff_member, only: %i[edit update destroy show]

    def index
      @staff_members = current_account.staff_members.order(:name)
    end

    def show
      @work_schedules = @staff_member.work_schedules.order(:day_of_week)
      @schedule_overrides = @staff_member.schedule_overrides.where("override_date >= ?", Date.current).order(:override_date)
    end

    def new
      @staff_member = current_account.staff_members.new(active: true)
      @services = current_account.services.active
    end

    def create
      @staff_member = current_account.staff_members.new(staff_member_params)
      if @staff_member.save
        update_service_assignments
        redirect_to admin_staff_member_path(@staff_member), notice: "Profissional '#{@staff_member.name}' cadastrado com sucesso!"
      else
        @services = current_account.services.active
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @services = current_account.services.active
    end

    def update
      if @staff_member.update(staff_member_params)
        update_service_assignments
        redirect_to admin_staff_member_path(@staff_member), notice: "Profissional '#{@staff_member.name}' atualizado com sucesso!"
      else
        @services = current_account.services.active
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @staff_member.destroy
        redirect_to admin_staff_members_path, notice: "Profissional removido com sucesso."
      else
        redirect_to admin_staff_members_path, alert: "Não é possível remover profissional com agendamentos ativos."
      end
    end

    private

    def set_staff_member
      @staff_member = current_account.staff_members.find(params[:id])
    end

    def staff_member_params
      params.require(:staff_member).permit(:name, :email, :phone, :bio, :avatar_url, :active)
    end

    def update_service_assignments
      return unless params[:staff_member][:service_ids]
      @staff_member.service_ids = params[:staff_member][:service_ids].reject(&:blank?)
    end
  end
end
