module Org
  class OrgansController < BaseController
    before_action :set_organ, only: [:show]
    before_action :authenticated?

    def index
      q_params = {
        production_enabled: true
      }
      if current_organ&.official
      elsif current_organ
        q_params.merge! provider_id: current_organ.id
      end

      if current_user&.address_principal
        geo = current_user.address_principal.geo
        if geo
          longitude = geo.longitude
          latitude = geo.latitude
        else
          longitude = session[:longitude]
          latitude = session[:latitude]
        end
      end

      @organs = Organ.includes(:organ_domains, :top_productions).with_attached_logo.json_filter_any(:dispatches, 'delivery').default_where(q_params).page(params[:page])
      if longitude && latitude
        @organs = @organs.near(longitude, latitude)
      else
        @organs = @organs.order(id: :asc)
      end
    end

    def form_search
      q_params = {}
      q_params.merge! params.permit('name-like')

      @organs = Organ.default_where(q_params)
    end

    private
    def set_organ
      @organ = Organ.find params[:id]
    end

  end
end
