module Admin
  class ServicesController < BaseController
    before_action :set_service, only: %i[edit update destroy toggle_active]

    def index
      @services = current_account.services.ordered
    end

    def new
      @service = current_account.services.new(duration_minutes: 60, currency: "BRL", active: true)
      @staff_members = current_account.staff_members.active
    end

    def create
      @service = current_account.services.new(service_params)
      if @service.save
        update_staff_assignments
        redirect_to admin_services_path, notice: "Serviço '#{@service.name}' criado com sucesso!"
      else
        @staff_members = current_account.staff_members.active
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @staff_members = current_account.staff_members.active
    end

    def update
      if @service.update(service_params)
        update_staff_assignments
        redirect_to admin_services_path, notice: "Serviço '#{@service.name}' atualizado com sucesso!"
      else
        @staff_members = current_account.staff_members.active
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @service.destroy
        redirect_to admin_services_path, notice: "Serviço excluído com sucesso."
      else
        redirect_to admin_services_path, alert: "Não é possível excluir um serviço que possui agendamentos associados."
      end
    end

    def toggle_active
      @service.update(active: !@service.active)
      status_str = @service.active? ? "ativado" : "desativado"
      redirect_to admin_services_path, notice: "Serviço #{status_str} com sucesso."
    end

    private

    def set_service
      @service = current_account.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :duration_minutes, :price_reais, :active, :position)
    end

    def update_staff_assignments
      return unless params[:service][:staff_member_ids]
      @service.staff_member_ids = params[:service][:staff_member_ids].reject(&:blank?)
    end
  end
end
