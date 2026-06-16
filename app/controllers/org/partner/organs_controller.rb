module Org
  class Partner::OrgansController < Panel::OrgansController

    def index
      q_params = {
        provider_id: current_organ.id
      }
      q_params.merge! params.permit(:id, 'name-like')

      @organs = Organ.roots.with_attached_logo.includes(:organ_domains, :roles, :owner).default_where(q_params).unscope(:order).order(id: :desc).page(params[:page])
    end

  end
end
