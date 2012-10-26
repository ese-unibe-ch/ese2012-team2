require_relative '../models/trade_exception'
class OrganizationDataHelper

  def self.new_organization (params, active_user)
    data = Models::DataOverlay.instance
    self.new_organization_checks(params)

    new_organization = data.new_organization(params[:name], params[:interests], active_user)
    new_organization.image = ImageHelper.save(params[:image],"#{settings.public_folder}/images/organizations")
    new_organization
  end

  def self.new_organization_checks params
    data = Models::DataOverlay.instance

    if params[:username] == ""
      raise TradeException, "Empty name"
    end

    if data.organization_exists?(params[:name])
      raise TradeException, "Organization already exists."
    end
  end

end