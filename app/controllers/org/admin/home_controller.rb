module Org
  class Admin::HomeController < Admin::BaseController

    def index
    end

    def toggle
      current_organ.auto_purchase = !current_organ.auto_purchase
      current_organ.save
    end

  end
end
