module RailsOrg #:nodoc:
  mattr_accessor :config, default: ActiveSupport::OrderedOptions.new

  config.independent = false
end


