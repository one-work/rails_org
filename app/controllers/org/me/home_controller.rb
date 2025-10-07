module Org
  class Me::HomeController < Me::BaseController
    skip_before_action :require_role

    def index
    end

  end
end
