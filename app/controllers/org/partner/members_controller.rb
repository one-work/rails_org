module Org
  class Partner::MembersController < Panel::MembersController
    include Org::Controller::Admin
    before_action :require_org_member

  end
end
