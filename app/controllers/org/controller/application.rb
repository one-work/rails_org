module Org
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_organ, :current_organ_domain, :current_member, :other_organs, :default_platform_params
    end

    private
    def current_member
      return @current_member if defined?(@current_member)

      if (request.subdomain == 'admin' || !RailsOrg.config.independent) && current_authorized_token
        @current_member = current_authorized_token.member || current_authorized_token.mocked_member
      elsif current_domain_organ
        @current_member = current_authorized_token&.member ||
          (defined?(current_wechat_user) && current_wechat_user && current_wechat_user.members.find_by(organ_id: current_domain_organ.self_and_ancestor_ids)) ||
          (current_account && current_account.members.find_by(organ_id: current_domain_organ.self_and_ancestor_ids)) ||
          defined?(current_corp_user) && current_corp_user&.member
      end

      if @current_member
        logger.debug "\e[35m  Login as member: #{@current_member.name}(#{@current_member.id})  \e[0m"
      else
        logger.debug "\e[35m  member is missing  \e[0m"
      end
      @current_member
    end

    def current_organ
      return @current_organ if defined?(@current_organ)

      if current_organ_domain
        @current_organ = current_organ_domain.organ
      elsif current_member
        @current_organ = current_member.organ
      end
      logger.debug "\e[35m  Login as organ: #{@current_organ&.name}, ID: #{@current_organ&.id}  \e[0m"
      @current_organ
    end

    def current_domain_organ
      return @current_domain_organ if defined?(@current_domain_organ)
      @current_domain_organ = current_organ_domain&.organ
    end

    def current_organ_domain
      return @current_organ_domain if defined?(@current_organ_domain)
      if RailsOrg.config.independent
        @current_organ_domain = OrganDomain.annotate('get organ domain in org application').find_by(host: request.host)
      end
    end

    def other_organs
      if current_organ
        current_user.organs.where.not(id: current_organ.id)
      else
        current_user.organs
      end
    end

    def default_params
      if current_organ
        { organ_id: current_organ.id }
      else
        super
      end
    end

    def default_form_params
      if current_organ
        { organ_id: current_organ.id }
      else
        super
      end
    end

    def default_filter_params
      if current_organ
        { organ_id: current_organ.self_and_descendant_ids }
      else
        default_params
      end
    end

    def default_ancestors_params
      if current_organ
        { organ_id: current_organ.self_and_ancestor_ids }
      else
        default_params
      end
    end

    def default_platform_params
      if current_organ
        { organ_id: [current_organ.id, nil] }
      else
        { organ_id: nil }
      end
    end

  end
end
