require_relative '../models/trade_exception'
require_relative '../models/organization'

class OrganizationDataHelper

  def self.new_organization (params, active_user)
    image = ImageHelper.save(params[:image],"#{settings.public_folder}/images/organizations")
    org = Models::Organization.new(params[:name], params[:interests], active_user, image)

    data = Models::DataOverlay.instance
    if data.organization_exists? org
      raise TradeException, "Organization already exists!"
    end
    data.add_organization(org)
  end

end