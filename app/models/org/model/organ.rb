module Org
  module Model::Organ
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :name_short, :string
      attribute :address, :string
      attribute :official, :boolean, default: false, comment: '是否官方'
      attribute :joinable, :boolean, default: false, comment: '是否可搜索并加入'
      attribute :code, :string
      attribute :license, :string
      attribute :service_url, :string, comment: '客服 url'
      attribute :theme_settings, :json, default: {}
      attribute :members_count, :integer

      if defined? RailsShip
        has_taxons :area
        belongs_to :area, class_name: 'Ship::Area', optional: true
      end
      belongs_to :creator, class_name: 'Auth::User', counter_cache: 'created_organs_count', optional: true
      belongs_to :provider, class_name: 'Org::Organ', optional: true

      has_many :organs, class_name: self.name, primary_key: :provider_id
      has_many :supports, -> { where(department_id: nil) }, dependent: :destroy_async
      has_many :departments, dependent: :destroy_async
      has_many :members, dependent: :destroy_async
      has_many :super_job_titles, dependent: :destroy_async
      has_many :organ_domains, dependent: :destroy_async

      accepts_nested_attributes_for :members

      has_one_attached :logo
      has_one_attached :bar_logo
      has_one_attached :bar_logo_invert

      scope :official, -> { where(official: true) }

      validates :name, presence: true
      validates :code, uniqueness: true, allow_blank: true
    end

    def address_detail
      "#{area&.full_name} #{address}"
    end

    def ancestral_members
      Member.where(organ_id: self_and_ancestor_ids)
    end

    def domain
      organ_domains.find(&:frontend?) || organ_domains.create
    end

    def host
      domain.host
    end

    def url_options(request = nil)
      if request.is_a? ActionDispatch::Request
        cur = { host: request.host, protocol: request.scheme }
        cur.merge! port: request.port.to_s unless request.port.to_s == '80'
        return cur if organ_domains.map(&:options).include?(cur)
      end

      od = organ_domains.find(&:frontend?) || organ_domains.create
      return od.options if od

      {}
    end

    def admin_domain
      organ_domains.find(&:backend?) || organ_domains.create(kind: 'backend')
    end

    def admin_host
      admin_domain.host
    end

    def agent_domain
      organ_domains.find(&:agent?) || organ_domains.create(kind: 'agent')
    end

    def agent_host
      agent_domain.host
    end

    def admin_url_options(request = nil, **options)
      r = admin_domain.options
      if request.is_a? ActionDispatch::Request
        r.merge! protocol: request.scheme
        r.merge! port: request.port.to_s unless request.port.to_s == '80'
        #return cur if request.host == admin_domain.host

        if options.key?(:auth_token) && request.host == admin_domain.host
          options.delete(:auth_token)
        end
      end

      r.merge!(options)
    end

    def mp_domain
      organ_domains.find(&:mp?) || organ_domains.create(kind: 'mp')
    end

    def mp_host
      mp_domain.host
    end

    def domains
      organ_domains.pluck(:host)
    end

    def admin?
      official?
    end

    def redirect_path(**options)
      domain.redirect_path(**options)
    end

    def redirect_url(**options)
      domain.redirect_url(**options)
    end

    def admin_theme
      r = theme_settings['admin_menu']
      if r
        {
          'admin-menu' => "hsl(#{r['hue']}, #{r['saturation']}%, #{r['lightness']}%)",
          'admin-menu-darker' => "hsl(#{r['hue']}, #{r['saturation']}%, #{(r['lightness'].to_i * 0.8).round}%)"
        }.compact_blank!.map(&->(k,v){ "--#{k}: #{v}" }).join('; ')
      else
        ''
      end
    end

    def panel_theme
      r = theme_settings['panel_menu']
      if r
        {
          'admin-menu' => "hsl(#{r['hue']}, #{r['saturation']}%, #{r['lightness']}%)",
          'admin-menu-darker' => "hsl(#{r['hue']}, #{r['saturation']}%, #{(r['lightness'].to_i * 0.8).round}%)"
        }.compact_blank!.map(&->(k,v){ "--#{k}: #{v}" }).join('; ')
      else
        ''
      end
    end

  end
end
