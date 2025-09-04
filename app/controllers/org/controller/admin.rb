module Org
  module Controller::Admin
    extend ActiveSupport::Concern

    def require_org_member
      return if current_organ && current_organ.self_and_ancestor_ids.include?(current_member&.organ_id)

      if Current.session
        render 'require_org_member', layout: 'simple'
      elsif defined? current_provider_app
        require_user(current_provider_app)
      else
        require_user
      end
    end

  end
end
