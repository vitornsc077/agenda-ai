module Admin
  class WorkSchedulesController < BaseController
    before_action :set_staff_member

    def index
      @work_schedules = @staff_member.work_schedules.order(:day_of_week)
    end

    def update
      params[:schedules]&.each do |schedule_id, schedule_data|
        schedule = @staff_member.work_schedules.find_by(id: schedule_id)
        next unless schedule

        schedule.update(
          start_time: schedule_data[:start_time],
          end_time: schedule_data[:end_time],
          enabled: schedule_data[:enabled] == "1" || schedule_data[:enabled] == true
        )
      end

      redirect_to admin_staff_member_path(@staff_member), notice: "Horários de atendimento atualizados com sucesso!"
    end

    private

    def set_staff_member
      @staff_member = current_account.staff_members.find(params[:staff_member_id])
    end
  end
end
