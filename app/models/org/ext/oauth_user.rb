module Org
  module Ext::OauthUser
    extend ActiveSupport::Concern

    included do
      has_many :temp_members, class_name: 'Org::Member', primary_key: :uid, foreign_key: :identity
      has_many :members, class_name: 'Org::Member', primary_key: :identity, foreign_key: :identity
      has_many :organs, class_name: 'Org::Organ', through: :members

      after_save :sync_to_temp_members, if: -> { saved_change_to_identity? && identity != uid }
    end

    def sync_to_temp_members
      self.temp_members.update_all(identity: identity)
    end

  end
end
