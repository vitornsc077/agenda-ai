module Admin
  module Api
    class AvailabilityController < BaseController
      def show
        staff_member = current_account.staff_members.find(params[:staff_member_id])
        target_date = Date.parse(params[:date])
        service = current_account.services.find(params[:service_id])

        engine = AvailabilityEngine.new(account: current_account)
        slots = engine.available_slots(
          date: target_date,
          service: service,
          staff_member: staff_member
        )

        render json: {
          date: target_date,
          slots: slots.map { |s| { start_time: s.start_time, end_time: s.end_time, starts_at: s.starts_at } }
        }
      end
    end
  end
end
