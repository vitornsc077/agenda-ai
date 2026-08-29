module Admin
  class ScheduleOverridesController < BaseController
    before_action :set_staff_member

    def create
      @override = @staff_member.schedule_overrides.new(override_params)
      if @override.save
        redirect_to admin_staff_member_path(@staff_member), notice: "Bloqueio/Exceção adicionado com sucesso!"
      else
        redirect_to admin_staff_member_path(@staff_member), alert: "Erro ao salvar exceção: #{@override.errors.full_messages.join(', ')}"
      end
    end

    def destroy
      @override = @staff_member.schedule_overrides.find(params[:id])
      @override.destroy
      redirect_to admin_staff_member_path(@staff_member), notice: "Exceção de horário removida com sucesso."
    end

    private

    def set_staff_member
      @staff_member = current_account.staff_members.find(params[:staff_member_id])
    end

    def override_params
      params.require(:schedule_override).permit(:override_date, :start_time, :end_time, :override_type, :reason)
    end
  end
end
