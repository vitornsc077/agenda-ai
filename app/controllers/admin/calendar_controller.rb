module Admin
  class CalendarController < BaseController
    def show
      @view_mode = params[:view] || "week" # "day", "week", "month"
      @current_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
      @selected_staff_id = params[:staff_member_id]
      @selected_service_id = params[:service_id]

      @staff_members = current_account.staff_members.active
      @services = current_account.services.active

      range = case @view_mode
              when "day"
                @current_date.beginning_of_day..@current_date.end_of_day
              when "month"
                @current_date.beginning_of_month.beginning_of_week..@current_date.end_of_month.end_of_week
              else # "week"
                @current_date.beginning_of_week..@current_date.end_of_week
              end

      @bookings = current_account.bookings
                                 .includes(:service, :staff_member, :client)
                                 .where(starts_at: range)
                                 .where.not(status: :cancelled)

      @bookings = @bookings.where(staff_member_id: @selected_staff_id) if @selected_staff_id.present?
      @bookings = @bookings.where(service_id: @selected_service_id) if @selected_service_id.present?
    end
  end
end
