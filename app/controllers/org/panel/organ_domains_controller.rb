module Org
  class Panel::OrganDomainsController < Panel::BaseController
    before_action :set_organ, except: [:all]
    before_action :set_organ_domain, only: [:show, :edit, :update, :destroy, :actions]
    before_action :set_new_organ_domain, only: [:new, :create]

    def index
      @organ_domains = @organ.organ_domains.page(params[:page])
    end

    def all
      @organ_domains = OrganDomain.page(params[:page])
    end

    private
    def set_organ
      @organ = Organ.find params[:organ_id]
    end

    def set_organ_domain
      @organ_domain = @organ.organ_domains.find(params[:id])
    end

    def set_new_organ_domain
      @organ_domain = @organ.organ_domains.build(organ_domain_params)
    end

    def organ_domain_params
      params.fetch(:organ_domain, {}).permit(
        :domain,
        :subdomain,
        :host,
        :default,
        :appid,
        :scheme,
        :kind,
        :beian,
        :redirect_controller,
        :redirect_action,
      )
    end

  end
end
