module Admin
  class DashboardController < BaseController
    def show
      @today_bookings = current_account.bookings.for_date(Date.current).order(starts_at: :asc)
      @upcoming_bookings = current_account.bookings.upcoming.limit(6)
      @total_clients_count = current_account.clients.count
      @total_services_count = current_account.services.active.count
      @total_staff_count = current_account.staff_members.active.count
      @monthly_bookings_count = current_account.bookings.where(starts_at: Time.current.beginning_of_month..Time.current.end_of_month).count
      @trial_service = TrialStatusService.new(current_account)
    end
  end
end
