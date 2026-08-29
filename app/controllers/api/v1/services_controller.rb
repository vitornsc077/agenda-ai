module Api
  module V1
    class ServicesController < BaseController
      def index
        services = current_account.services.order(:position, :created_at)
        render json: {
          status: "success",
          account: {
            name: current_account.name,
            slug: current_account.slug,
            public_url: public_booking_url(slug: current_account.slug)
          },
          services: services.map { |s| service_json(s) }
        }
      end

      def create
        service = current_account.services.new(service_params)

        # Associate all active staff members by default if none explicitly specified
        if service.staff_member_ids.blank?
          service.staff_member_ids = current_account.staff_members.where(active: true).pluck(:id)
        end

        if service.save
          render json: {
            status: "success",
            message: "Serviço '#{service.name}' cadastrado com sucesso no AgendaAI!",
            service: service_json(service),
            public_booking_url: public_booking_url(slug: current_account.slug, service_id: service.id)
          }, status: :created
        else
          render json: {
            status: "error",
            message: "Erro ao cadastrar serviço",
            errors: service.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def service_params
        params.permit(:name, :description, :duration_minutes, :price_reais, :price_cents, :active, staff_member_ids: [])
      end

      def service_json(service)
        {
          id: service.id,
          name: service.name,
          description: service.description,
          duration_minutes: service.duration_minutes,
          price_cents: service.price_cents,
          price_formatted: service.formatted_price,
          active: service.active,
          staff_count: service.staff_members.count,
          created_at: service.created_at.iso8601
        }
      end
    end
  end
end
