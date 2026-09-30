module Org
  class Me::MembersController < Me::BaseController
    include Org::Layout::Me
    before_action :set_member, only: [:show, :edit, :update, :destroy, :qrcodes]

    def qrcodes
      if @member.invitable?
        @scene = @member.invite_member!
        if @scene
          @requests = @scene.requests.includes(:wechat_user).page(params[:page])
        else
          @requests = Wechat::Request.none
        end
      else
        render :alert_message, locals: { message: '您暂无权限邀请新成员，请联系管理员!' }
      end
    end

    def mall
      Current.session.update member_id: current_member.id

      redirect_to(
        {
          controller: 'factory/productions',
          host: "mall.#{Rails.app.routes.default_url_options[:host]}",
          auth_token: Current.session.once_token
        },
        allow_other_host: true
      )
    end

    private
    def set_member
      @member = current_member
    end

    def member_params
      params.fetch(:member, {}).permit(
        :name,
        :avatar
      )
    end

  end
end
