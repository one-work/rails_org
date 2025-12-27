module Org
  class OrgansController < BaseController
    before_action :set_organ, only: [:show]

    def index
      q_params = {
        parent_id: current_organ.id,
        allow: { parent_id: nil }
      }

      @organs = Organ.with_attached_logo.default_where(q_params).order(id: :desc).page(params[:page])
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
