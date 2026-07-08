module Org
  class JobTransfer < ApplicationRecord
    include Model::JobTransfer
    include Notice::Ext::Notifiable
    include Notice::Ext::MemberNotifiable
  end
end
