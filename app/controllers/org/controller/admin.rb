module Org
  module Controller::Admin
    extend ActiveSupport::Concern

    def require_org_member
      return if current_member #&& current_organ && current_organ.self_and_ancestor_ids.include?(current_member.organ_id)

      if Current.session
        if current_user
          members = current_user.members.includes(:organ)
        else
          members = Member.none
        end

        if members.blank?
          if current_organ
            render 'require_org_member'
          else
            roles = Roled::Role.visible.where.not(tip: nil)
            render 'add_org_member', layout: 'admin_add_member', locals: { roles: roles }
          end
        elsif members.size == 1
          Current.session.update member_id: members.first.id
          @current_member = Current.session.member
          @current_organ = current_member.organ
          return
        else
          render 'choose_org_member', locals: { members: members }
        end
        set_auth_token # 在这里渲染了模板，不会调用 after_action
      else
        if defined? current_provider_app
          require_user(current_provider_app)
        else
          require_user
        end
      end
    end

  end
end
