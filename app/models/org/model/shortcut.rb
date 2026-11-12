module Org
  module Model::Shortcut
    extend ActiveSupport::Concern

    included do
      attribute :controller, :string
      attribute :action, :string, default: 'index'
      attribute :business, :string
      attribute :namespace, :string

      has_one :meta_action, class_name: 'Meta::Action', primary_key: [:controller, :action], foreign_key: [:controller_path, :action_name]

      belongs_to :member
    end

    def name
      I18n.t "#{controller.tr('/', '.')}.#{action}.title", default: nil
    end

  end
end
