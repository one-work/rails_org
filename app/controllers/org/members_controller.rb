module Org
  class MembersController < BaseController
    before_action :set_member, only: [:show]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit('name-like')

      @members = Member.includes(:departments, avatar_attachment: :blob).where(enabled: true).default_where(q_params).page(params[:page]).per(30)
    end

    def search
      if params[:q].present?
        @members = Member.where(enabled: true).default_where('name-like': params[:q])
      else
        @members = Member.none
      end

      render json: { results: @members.as_json(only: [:name, :id]) }
    end

    def people
      @members = Member.where(enabled: true)
    end

    def journals
      @journals = Journal.all
    end

    def sections
      @sections = Department.find_all_by_generation(1)
    end

    def groups
      @groups = Department.find_all_by_generation(2)
    end

    private
    def set_member
      @member = Member.find(params[:id])
    end

  end
end
