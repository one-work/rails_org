module Org
  class Member < ApplicationRecord
    include Model::Member
    include Roled::Ext::Member
    include Wechat::Ext::Member if defined? RailsWechat
    if defined? RailsNotice
      include Notice::Ext::Member
      include Notice::Ext::Setting
    end
    include Crm::Ext::Member if defined? RailsCrm
    include Trade::Ext::Member if defined? RailsTrade
    include Finance::Ext::Member if defined? RailsFinance
    include Bench::Ext::Member if defined? RailsBench
    include Ship::Ext::Member if defined? RailsShip
  end
end
