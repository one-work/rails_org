module Org
  module Ext::Session
    extend ActiveSupport::Concern

    included do
      attribute :mock_member, :boolean

      belongs_to :member, class_name: 'Org::Member', optional: true
    end

    def mocked_member
      if mock_member
        member
      else
        nil
      end
    end

  end
end
