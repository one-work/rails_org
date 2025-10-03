module Org
  class Board::MembersController < Board::BaseController
    before_action :set_member, only: [:show, :edit, :update]

    def login
      @member = current_user.members.find(params[:id])

      if request.subdomain == 'admin'
        Current.session.update member_id: member.id
        redirect_to '/'
      else
        refresh_or_redirect_to({ controller: '/me/home', host: @organ.admin_host, auth_token: member.auth_token }, allow_other_host: true)
      end
    end

    def logout
      Current.session.update member_id: nil
      refresh_or_redirect_to({ controller: 'org/board/organs' })
    end

    private
    def set_member
      @member = current_user.members.find(params[:id])
    end

  end
end
