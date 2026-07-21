module Org
  module Controller::Panel
    extend ActiveSupport::Concern

    def current_organ
      return @current_organ if defined?(@current_organ)
      return if params[:namespace] == 'panel' && Rails.app.routes.default_url_options[:host] == request.host

      if current_organ_domain
        @current_organ = current_organ_domain.organ
      elsif current_member
        @current_organ = current_member.organ
      end
      logger.debug "\e[35m  Login as organ: #{@current_organ&.name}, ID: #{@current_organ&.id}  \e[0m"
      @current_organ
    end

  end
end
