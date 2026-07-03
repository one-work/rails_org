module Org
  class Partner::OrgansController < Panel::OrgansController
    include Org::Controller::Admin
    before_action :require_org_member

    def index
      q_params = {
        provider_id: current_organ.id
      }
      q_params.merge! params.permit(:id, 'name-like')

      Current.session.update mock_member: false
      @organs = Organ.roots.with_attached_logo.includes(:organ_domains, :roles, :owner).default_where(q_params).unscope(:order).order(id: :desc).page(params[:page])
    end

    private
    def set_new_organ
      @organ = Organ.new(organ_params)
      @organ.provider = current_organ
    end

  end
end
