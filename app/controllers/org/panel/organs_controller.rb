module Org
  class Panel::OrgansController < Panel::BaseController
    before_action :set_organ, only: [:show, :edit, :update, :edit_roles, :children]

    def index
      q_params = {}
      q_params.merge! params.permit(:id, 'name-like')

      @organs = Organ.roots.with_attached_logo.includes(:organ_domains, :roles, :owner).default_where(q_params).unscope(:order).order(id: :desc).page(params[:page])
    end

    def search
      @organs = Organ.default_where('name-like': params['name-like'])
    end

    def new
      @organ = Organ.new
      @organ.area = Ship::Area.root || Ship::Area.new if defined? RailsShip
    end

    def show
      @scene = @organ.invite_member!
      render :show, locals: { model: @organ }
    end

    def edit
      if defined? RailsShip
        @organ.area || @organ.build_area
      end
    end

    def edit_roles
      @roles = @organ.visible_roles
    end

    def children
      @organs = @organ.children.page(params[:page])
    end

    private
    def set_organ
      @organ = Organ.find params[:id]
    end

    def organ_params
      params.fetch(:organ, {}).permit(
        :name,
        :code,
        :logo,
        :official,
        :name_short,
        :license,
        :parent_ancestors,
        :area_ancestors,
        role_whos_attributes: [:id, :role_id, :_destroy]
      )
    end

    def organ_limit_params
      params.fetch(:organ, {}).permit(
        :limit_office,
        :limit_wechat
      )
    end

  end
end
