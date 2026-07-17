module Org
  class OrgansController < BaseController
    before_action :set_organ, only: [:show]

    def index
      q_params = {
        production_enabled: true
      }
      if current_organ
        q_params.merge! provider_id: current_organ.id
      end

      @organs = Organ.includes(:organ_domains).with_attached_logo.default_where(q_params).page(params[:page])

      if params[:longitude] && params[:latitude]
        @organs = @organs.near(params[:longitude], params[:latitude])
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
