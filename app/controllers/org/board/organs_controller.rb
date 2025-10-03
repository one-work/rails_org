module Org
  class Board::OrgansController < Board::BaseController
    before_action :set_organ, only: [:show, :edit, :update, :redirect, :destroy]
    before_action :set_new_organ, only: [:index, :new]
    before_action :set_create_organ, only: [:create]
    before_action :set_roles, only:[:index, :new, :create]

    def index
      q_params = {}
      #q_params.merge! provider_id: [current_organ.id, nil] if current_organ
      q_params.merge! 'who_roles.role_id' => params[:role_id] if params[:role_id].present?

      @oauth_users = current_user.oauth_users.each_with_object({}) { |k, h| h[k] = k.organs.default_where(q_params) }
    end

    def create
      if @organ.save
        Current.session.update member_id: @member.id
        redirect_to '/'
      else
        render :new, locals: { model: @organ }, status: :unprocessable_entity
      end
    end

    private
    def set_organ
      @organ = current_user.organs.find(params[:id])
    end

    def set_new_organ
      @organ = Organ.new(organ_params)
      @organ.role_whos.build(role_id: params[:role_id]) if params[:role_id].present?
    end

    def set_create_organ
      @organ = Organ.new(organ_params)
      @member = @organ.members.build(
        identity: Current.session.identity,
        owned: true,
        **organ_params.slice(:role_whos_attributes)
      )
      @member.wechat_openid = Current.session.uid if @member.respond_to? :wechat_openid
    end

    def set_roles
      if params[:role_id].present?
        @roles = Roled::Role.visible.where(id: params[:role_id])
      else
        @roles = Roled::Role.visible.where.not(tip: nil)
      end
    end

    def organ_params
      _p = params.fetch(:organ, {}).permit(
        :name,
        :logo,
        role_whos_attributes: [:role_id]
      )
      _p.merge! provider_id: current_organ.id if current_organ
      _p
    end

  end
end
