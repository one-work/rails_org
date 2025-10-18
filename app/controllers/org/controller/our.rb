module Org
  module Controller::Our
    extend ActiveSupport::Concern

    included do
      before_action :require_client
    end

    def require_organ
      return if current_organ

      raise ActionController::RoutingError, 'Not Found'
    end

    def require_client
      return if current_client

      redirect_to url_for(controller: 'trade/our/carts', action: 'list', **params.permit(:auth_token, :role_id))
    end

    def set_roled_tabs
      if defined?(current_organ) && current_organ
        @roled_tabs = current_organ.tabs.where(namespace: 'our').load.sort_by(&:position)
      else
        @roled_tabs = Roled::Tab.none
      end
      logger.debug "\e[35m  Our SetRoleTabs: #{@roled_tabs}  \e[0m" if RailsCom.config.debug
    end

  end
end
