class PartnerController < PanelController
  include Org::Controller::Admin
  before_action :require_org_member

end
