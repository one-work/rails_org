module Org

  def self.use_relative_model_naming?
    true
  end

  def self.table_name_prefix
    'org_'.freeze
  end

end
