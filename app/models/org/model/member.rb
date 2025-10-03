
module Org
  module Model::Member
    extend ActiveSupport::Concern

    included do
      attribute :identity, :string, default: '', index: true
      attribute :experience, :string
      attribute :attendance_number, :string
      attribute :organ_root_id, :integer
      attribute :name, :string
      attribute :number, :string
      attribute :join_on, :date, default: -> { Date.today }
      attribute :enabled, :boolean, default: true
      attribute :inviter, :boolean, default: false
      attribute :owned, :boolean, default: false

      enum :state, {
        init: 'init',
        pending_trial: 'pending_trial',
        approved: 'approved'
      }, default: 'init'

      has_many :oauth_users, class_name: 'Auth::OauthUser', primary_key: [:identity, :wechat_openid], foreign_key: [:identity, :uid]
      has_many :users, class_name: 'Auth::User', through: :oauth_users
      has_many :sessions, class_name: 'Auth::Session', primary_key: :identity, foreign_key: :identity

      belongs_to :organ, counter_cache: true, inverse_of: :members

      has_many :shortcuts

      has_many :member_departments, dependent: :delete_all
      has_many :departments, through: :member_departments
      has_many :job_titles, through: :member_departments
      has_many :members, through: :member_departments, source: :members
      accepts_nested_attributes_for :member_departments, reject_if: :all_blank, allow_destroy: true

      has_many :inferior_member_departments, class_name: 'Org::MemberDepartment', foreign_key: :superior_id, primary_key: :department_ids

      has_one :resign
      has_one :tutorial, ->{ order(created_at: :desc) }, dependent: :nullify
      has_one :tutor, through: :tutorial
      has_many :tutorials, dependent: :nullify
      has_many :tutorings, class_name: 'Org::Tutorial', foreign_key: :tutor_id
      has_many :tutees, through: :tutorings, source: :member
      #has_many :job_transfers, dependent: :destroy_async

      has_one_attached :avatar
      has_one_attached :resume

      scope :enabled, -> { where(enabled: true) }
      scope :inviter, -> { where(inviter: true) }

      validates :identity, uniqueness: { scope: :organ_id }, allow_blank: true

      has_taxons :department

      #before_save :sync_tutorials, if: -> { join_on_changed? }
      #before_save :sync_avatar_from_user, if: -> { identity_changed? && user }
      after_create_commit :increment_counts_to_users
    end

    def set_current_cart(organ_id)
      cart = carts.find_or_initialize_by(organ_id: organ_id)
      cart.save if cart.persisted?
    end

    def admin?
      return true if owned?
      if account
        account.user_id == organ.creator_id
      elsif wechat_user
        wechat_user.user_id == organ.creator_id
      else
        organ.member_ids.all?(id)
      end
    end

    def grade
      member_departments.minimum(:grade)
    end

    def display_name
      name.presence || "member_#{id}"
    end

    def sync_avatar_from_user
      self.name ||= user.name
      self.avatar_blob ||= user.avatar_blob
    end

    def direct_follower_ids
      member_departments.map do |md|
        md.direct_followers.pluck(:member_id)
      end.flatten.uniq
    end

    def direct_followers
      Member.where(id: direct_follower_ids)
    end

    def all_follower_ids
      (member_departments.map do |md|
        md.self_and_descendants.pluck(:member_id)
      end.flatten + [self.id]).uniq
    end

    def all_followers
      Member.where(id: all_lower_ids)
    end

    def lower_job_title_ids
      job_titles.map(&:lower_job_title_ids).flatten.uniq
    end

    def all_lower_ids
      MemberDepartment.where(job_title_id: lower_job_title_ids).pluck(:member_id)
    end

    def leader
    end

    def get_organ_grant
      at = account.authorized_token
      at.update member_id: self.id
      at
    end

    def mock_organ_grant(user_id)
      grant = self.organ_grants.find_or_create_by(user_id: user_id)
      unless grant.verify_token?
        grant.update_token!
      end
      grant
    end

    def leading_members
      Member.where(department_id: leading_department.self_and_descendant_ids)
    end

    def leading_member_ids
      leading_members.pluck(:id)
    end

    def leading_highest_department
      leading_departments = self.leading_departments
      unless leading_departments.empty?
        leading_departments = self.leading_departments.sort_by(&:depth)
      end
      leading_departments.first
    end

    def all_shortcuts
      shortcuts.load.each_with_object({}) do |i, h|
        h.merge! "#{i.controller}/#{i.action}" => i.id
      end
    end

    def auth_token
      session = sessions.where(mock_member: true, member_id: id).effective.take || sessions.create! do |m|
        m.member_id = id
        m.mock_member = true
        m.uid = wechat_openid if defined?(wechat_openid)
      end
      session.id
    end

    def increment_counts_to_users
      if owned
        counter = { owned: 1 }
      else
        counter = { joined: 1 }
      end

      users.each do |user|
        user.update_json_counter(**counter)
      end
    end

  end
end
