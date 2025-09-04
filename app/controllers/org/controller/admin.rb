module Org
  module Controller::Admin
    extend ActiveSupport::Concern

    def require_org_member
      return if current_organ && current_organ.self_and_ancestor_ids.include?(current_member&.organ_id)

      if Current.session
        if current_organ
          render 'require_org_member', layout: 'simple'
        else
          if current_account
            members = current_account.members.includes(:organ)
          elsif current_user
            members = current_user.members.includes(:organ)
          else
            members = Member.none
          end

          if members.blank?
          else
            render 'choose_org_member', layout: 'simple', locals: { members: members }
          end
        end
      elsif defined? current_provider_app
        require_user(current_provider_app)
      else
        require_user
      end
    end

  end
end
