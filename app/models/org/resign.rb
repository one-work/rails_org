module Org
  class Resign < ApplicationRecord
    include Model::Resign
    include Notice::Ext::Notifiable
    include Notice::Ext::MemberNotifiable
  end
end
