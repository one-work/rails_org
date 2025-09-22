module Org
  module Ext::User
    extend ActiveSupport::Concern

    included do
      attribute :created_organs_count, :integer, default: 0

      has_many :account_members, class_name: 'Org::Member', through: :accounts, source: :members
      has_many :oauth_user_members, class_name: 'Org::Member', through: :oauth_users, source: :members
      has_many :created_organs, class_name: 'Org::Organ', foreign_key: :creator_id

      after_save :copy_avatar_to_members, if: -> { attachment_changes['avatar'].present? }
    end

    def members
      identities = accounts.pluck(:identity)
      uids = oauth_users.pluck(:uid)

      if uids.present? && identities.present?
        Member.where(identity: identities).or(Member.where(wechat_openid: uids))
      elsif identities.present?
        Member.where(identity: identities)
      elsif uids.present?
        Member.where(wechat_openid: uids)
      end
    end

    def organs
      organ_ids = members.pluck(:organ_id)
      Organ.where(id: organ_ids.uniq)
    end

    def available_account_identities
      accounts.where.not(identity: members.pluck(:identity)).confirmed
    end

    def copy_avatar_to_members
      members.each do |member|
        member.avatar.attach attachment_changes['avatar'].blob if member.avatar.blank?
      end
    end

    def init_avatar_to_members
      members.each do |member|
        member.avatar.attach avatar_blob if avatar_blob
      end
    end

  end
end
