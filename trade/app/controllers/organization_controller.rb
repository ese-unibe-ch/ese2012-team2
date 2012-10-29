require_relative '../models/item'
require_relative '../models/user'
require_relative '../models/organization'
require_relative 'base_secure_controller'
require_relative '../helpers/image_helper'
require_relative '../helpers/organization_data_helper'

class OrganizationController  < BaseSecureController
   get "/organization/add" do
     @title = "Add organization"
     haml :add_organization
   end

   post "/organization/add" do
     @title = "Add organization"
     begin
       new_organization = OrganizationDataHelper.new_organization(params, @active_user)
       add_message("Successfully added organization #{new_organization.name}.", :success)
     rescue TradeException => e
       add_message(e.message, :error)
     end
     haml :add_organization
   end

  get "/organization/:organization" do
    organization = @data.organization_by_name(params[:organization])
    haml :organization, :locals => {:organization => organization}
  end

   post "/work_for" do
     work_for= params[:work_for]
     if work_for.nil?
      @active_user.working_for=nil
     else
       @active_user.working_for=@data.organization_by_name(work_for)
     end

     redirect "/index"
   end
end