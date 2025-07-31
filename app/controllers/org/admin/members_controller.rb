module Org
  class Admin::MembersController < Admin::BaseController
    before_action :set_member, only: [:show, :edit, :update, :mock, :edit_roles, :token, :destroy]
    before_action :set_new_member, only: [:new, :create, :options]

    def index
      q_params = {
        enabled: true
      }
      q_params.merge! default_filter_params
      q_params.merge! params.permit(:id, :identity, :organ_id, 'name-like', :enabled, :department_ancestors)
      #department = Department.find_by id: Member.new(q_params).department_ancestors&.values.to_a.compact.last
      #q_params.merge! department_id: department.self_and_descendant_ids if department
      @members = Member.includes(:organ, :roles, member_departments: [:job_title, :department]).default_where(q_params).order(id: :desc).page(params[:page])
    end

    def leaders
      if params[:q].present?
        @members = Member.default_where('name-like': params[:q])
      elsif params[:department_ids].present?
        department_id = params[:department_ids].split(',')[-2]
        @members = Member.where(department_id: department_id)
      else
        @members = Member.none
      end

      results = []
      @members.each do |member|
        results << { name: member.name, id: member.id }
      end
      render json: { results: results }
    end

    def new
      @member.join_on ||= Date.today
      @member.member_departments.build(department_id: params[:department_id])
    end

    def options
      @department = Department.find(params[:node_id]) if params[:node_id]
      @member_department = @member.member_departments.build(department_id: params[:node_id])
    end

    def edit_roles
      @roles = @member.visible_roles
    end

    def edit
      if @member.member_departments.count == 0
        @member.member_departments.build(department_id: params[:department_id])
      end
    end

    def mock
      organ_grant = @member.mock_organ_grant(current_user.id)
      Current.session.update member_id: @member.id
    end

    def add_item
      @member = Member.new
      @member.member_departments.build
    end

    def remove_item
    end

    def token
      @member.refresh_organ_token
      redirect_back fallback_location: admin_members_url
    end

    private
    def set_member
      @member = Member.find(params[:id])
    end

    def set_new_member
      @member = current_organ.members.build(member_params)
    end

    def member_params
      params.fetch(:member, {}).permit(
        :name,
        :identity,
        :type,
        :join_on,
        :enabled,
        :avatar,
        member_departments_attributes: {},
        role_whos_attributes: {}
      )
    end

  end
end
