module Org
  class Panel::MembersController < Panel::BaseController
    before_action :set_organ, except: [:all]
    before_action :set_member, only: [:show, :edit, :update, :destroy, :actions, :mock, :edit_roles]
    before_action :set_new_member, only: [:new, :create]
    before_action :set_filter_columns, only: [:index, :all]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, :identity, 'name-like', :enabled)

      @members = @organ.members.includes(:roles).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def all
      q_params = {}
      q_params.merge! params.permit(:wechat_openid, :identity, 'name-like')

      @members = Member.includes(:organ).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def mock
      redirect_to(
        { controller: '/admin/home', host: @organ.admin_host, auth_token: @member.auth_token },
        allow_other_host: true,
        status: :see_other
      )
    end

    def edit_roles
      @roles = @member.visible_roles
    end

    private
    def set_organ
      @organ = Organ.find params[:organ_id]
    end

    def set_member
      @member = @organ.members.find(params[:id])
    end

    def set_new_member
      @member = @organ.members.build member_params
    end

    def set_filter_columns
      @filter_columns = set_filter_i18n(
        'name-like' => { type: 'search', default: true },
        'identity' => { type: 'search', default: true },
        'wechat_openid' => { type: 'search', default: true }
      )
    end

    def member_params
      params.fetch(:member, {}).permit(
        :name,
        :identity,
        :join_on,
        :enabled,
        :owned,
        :wechat_openid,
        :corp_userid,
        :avatar,
        role_whos_attributes: [:id, :role_id, :_destroy],
        member_departments_attributes: {},
      )
    end

  end
end
