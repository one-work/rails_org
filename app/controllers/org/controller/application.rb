module Org
  module Controller::Application
    extend ActiveSupport::Concern

    included do
      helper_method :current_organ, :current_organ_domain, :current_member, :other_organs, :default_platform_params
    end

    private
    def current_member
      return @current_member if defined?(@current_member)

      resume_session
      if request.subdomain == 'admin' && Current.session
        @current_member = Current.session.member
      elsif current_organ_domain
        @current_member = Current.session&.member ||
          (defined?(current_user) && current_user && current_user.members.find_by(organ_id: current_organ_domain.organ.self_and_ancestor_ids)) ||
          defined?(current_corp_user) && current_corp_user&.member
      else
        @current_member = Current.session&.member
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
      else
        @current_organ = nil
      end
      logger.debug "\e[35m  Login as organ:  #{@current_organ&.name}, ID: #{@current_organ&.id}  \e[0m"
      @current_organ
    end

    def current_organ_domain
      return @current_organ_domain if defined?(@current_organ_domain)
      @current_organ_domain = OrganDomain.annotate('get organ domain in org application').find_by(host: request.host)
    end

    def choose_only_member
      members = current_user.members.includes(organ: :cache)
      if members.size == 1
        Current.session.update member_id: members.first.id
        @current_member = Current.session.member
        @current_organ = current_member.organ
      end
      members
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
