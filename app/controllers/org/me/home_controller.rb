module Org
  class Me::HomeController < Me::BaseController
    skip_before_action :require_role, only: [:index] if whether_filter :require_role

    def index
    end

  end
end
