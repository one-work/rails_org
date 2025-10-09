module Org
  class Me::OrgansController < Me::BaseController
    include Org::Layout::Me
    before_action :set_organ, only: [:show, :edit, :update, :destroy]

    def index
      @organs = current_organ.children
      if @organs.blank?
        redirect_to controller: '/me/home'
      end
    end

    def destroy
      if current_member.owned?
        @organ.destroy
      end
    end

    private
    def set_organ
      @organ = current_member.organ
    end

  end
end
