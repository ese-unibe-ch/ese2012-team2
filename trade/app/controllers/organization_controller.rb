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
     unless work_for.nil?
       session[:working_for] = work_for
     end
     redirect "/index"
   end

   post "/organization/:organization/remove_member/:member" do
     organization = @data.organization_by_name(params[:organization])
     member = @data.user_by_name params[:member]

     if @active_user == organization.admin
        organization.remove_member(member)
     end
     redirect back
   end

   post "/organization/:organization/add_member" do
     organization = @data.organization_by_name(params[:organization])
     member = @data.user_by_name params[:user]

     if @active_user == organization.admin
       organization.send_request(member)
     end
     redirect back
   end

  post "/organization/:organization/accept_request" do
    organization = @data.organization_by_name(params[:organization])
    organization.accept_request @active_user
    redirect back
  end

   post "/organization/:organization/decline_request" do
     organization = @data.organization_by_name(params[:organization])
     organization.decline_request @active_user
     redirect back
   end

   get "/user/:user/requests" do
     haml :organization_request
   end

end