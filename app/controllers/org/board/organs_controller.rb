module Org
  class Board::OrgansController < Board::BaseController
    before_action :set_organ, only: [:show, :edit, :update, :redirect, :destroy]
    before_action :set_new_organ, only: [:index, :new]
    before_action :set_create_organ, only: [:create, :create_admin]
    before_action :set_roles, only:[:index, :new, :create]

    def index
      q_params = {}
      if current_organ
        q_params.merge! organ: { provider_id: current_organ.id }
      elsif Organ.official.present?
        q_params.merge! organ: { provider_id: Organ.official.take.id }
      end

      @members = current_user.members.includes(:organ).where(q_params)
    end

    def create
      if @organ.save
        Current.session.update member_id: @member.id
      else
        render :new, locals: { model: @organ }, status: :unprocessable_entity
      end
    end

    def create_admin
      if @organ.save
        if ['admin', 'partner'].include?(request.subdomain)
          Current.session.update member_id: @member.id
          url = '/'
        elsif ['demo'].include?(request.subdomain)
          Current.session.update member_id: @member.id
          url = request.referer || '/'
        else
          url = url_for(controller: '/admin/home', host: @member.organ.admin_host, auth_token: @member.auth_token)
        end

        render locals: { url: url }
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
    end

    def set_create_organ
      @organ = Organ.new(organ_params)
      @member = @organ.members.build(
        identity: Current.session.identity,
        owned: true
      )
    end

    def set_roles
      @roles = Roled::Role.visible.where(subdomain: request.subdomain)
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
