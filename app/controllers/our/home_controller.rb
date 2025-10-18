module Our
  class HomeController < My::HomeController
    include Org::Controller::Our
    before_action :set_roles, only: [:organs]

    def index
    end

    def organs
      @organs = current_account.organs.includes(:organ_domains)
    end

    private
    def set_roles
      if params[:role_id].present?
        @roles = Roled::Role.visible.where(id: params[:role_id])
      else
        @roles = Roled::Role.visible
      end
    end

  end
end
