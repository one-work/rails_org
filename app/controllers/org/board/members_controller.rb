module Org
  class Board::MembersController < Board::BaseController
    before_action :set_member, only: [:show, :login, :edit, :update]

    def login
      if ['admin', 'demo'].include? request.subdomain
        Current.session.update member_id: @member.id
        redirect_to '/'
      else
        refresh_or_redirect_to({ controller: '/me/home', host: @member.organ.admin_host, auth_token: @member.auth_token }, allow_other_host: true)
      end
    end

    def logout
      Current.session.update member_id: nil, mock_member: false

      if current_user
        members = choose_only_member
      else
        members = Member.none
      end
      render 'choose_org_member', layout: 'admin_choose_member', locals: { members: members }
    end

    private
    def set_member
      @member = current_user.members.find(params[:id])
    end

  end
end
