module Org
  module Ext::OauthUser
    extend ActiveSupport::Concern

    included do
      has_many :members, class_name: 'Org::Member', foreign_key: :identity, primary_key: :identity
      has_many :organs, ->{ includes(:organ_domains) }, class_name: 'Org::Organ', through: :members
    end

  end
end
