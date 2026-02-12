module Org
  module Model::OrganDomain
    extend ActiveSupport::Concern
    KIND = {
      'frontend' => 'org',
      'backend' => 'admin',
      'mp' => 'mp',
      'agent' => 'agent'
    }

    included do
      attribute :subdomain, :string
      attribute :domain, :string, default: Rails.application.routes.default_url_options[:host]
      attribute :host, :string, index: true
      attribute :default, :boolean, default: false
      attribute :beian, :string, comment: '备案号'
      attribute :redirect_controller, :string, default: '/home'
      attribute :redirect_action, :string, default: 'index', comment: '默认跳转'

      enum :scheme, {
        http: 'http',
        https: 'https'
      }, default: Rails.application.routes.default_url_options[:protocol].presence || 'https'

      enum :kind, {
        frontend: 'frontend',
        backend: 'backend',
        mp: 'mp',
        agent: 'agent'
      }, default: 'frontend'

      belongs_to :organ

      validates :host, uniqueness: { scope: :kind }

      after_initialize :init_subdomain, if: -> { new_record? && subdomain.nil? }
      before_validation :compute_host, if: -> { (changes.keys & ['domain', 'subdomain']).present? }
      after_update :set_default, if: -> { default? && saved_change_to_default? }
    end

    def set_default
      self.class.where.not(id: self.id).where(organ_id: self.organ_id).update_all(default: false)
    end

    def compute_host
      self.host = [subdomain.presence, domain].compact.join('.')
    end

    def init_subdomain
      if RailsOrg.config.independent
        self.subdomain = [organ_id, KIND[kind]].join('.')
      end
      compute_host
    end

    def options
      {
        host: host || Rails.application.routes.default_url_options[:host],
        protocol: scheme.presence || Rails.application.routes.default_url_options[:protocol]
      }
    end

    def url
      URI::Generic.build(
        host: host,
        scheme: scheme
      ).to_s
    end

    def redirect_url(**options)
      x_options = {
        protocol: scheme,
        host: host,
        controller: redirect_controller.presence || 'home',
        action: redirect_action.presence || 'index'
      }
      x_options.merge! options

      Rails.app.routes.url_for(**x_options)
    end

    def redirect_path(**options)
      redirect_url(only_path: true, **options)
    end

  end
end
