require_relative '../models/trade_exception'
require_relative '../models/organization'

class OrganizationDataHelper

  def self.new_organization (params, active_user)
    data = Models::DataOverlay.instance

    if data.organization_exists? self.trim_name(params[:name])
      raise TradeException, "Organization already exists!"
    end

    image = ImageHelper.save(params[:image],"#{settings.public_folder}/images/organizations")
    Models::Organization.new(params[:name], params[:interests], active_user, image)
  end

  def self.trim_name name
    name.downcase.delete(" ")
  end

end