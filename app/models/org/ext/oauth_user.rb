module Org
  module Ext::OauthUser
    extend ActiveSupport::Concern

    included do
      has_many :members, class_name: 'Org::Member', primary_key: :identity, foreign_key: :identity
      has_many :organs, class_name: 'Org::Organ', through: :members
    end

  end
end
