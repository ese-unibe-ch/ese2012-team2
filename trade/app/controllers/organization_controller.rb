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
       flash.now[:success] = "Successfully added organization #{new_organization.name}."
     rescue TradeException => e
       flash.now[:error] = e.message
     end
     haml :add_organization
   end

  get "/organization/:organization" do
    organization = @data.organization_by_name(params[:organization])
    @title = "Organization" + organization.name
    haml :organization, :locals => {:organization => organization}
  end

   post "/work_for" do
     work_for= params[:work_for]
     puts "work for: " + work_for
     unless work_for.nil?
       session[:working_for] = work_for
     end
     flash[:success] = "You are now working for #{work_for}"
     redirect back
   end

   post "/organization/:organization/remove_member/:member" do
     organization = @data.organization_by_name(params[:organization])
     member = @data.user_by_name params[:member]

     if organization.admins.include? @active_user
        organization.remove_member(member)
     end
     flash[:success] = "Removed user #{member}"
     redirect back
   end

   post "/organization/:organization/add_member" do
     organization = @data.organization_by_name(params[:organization])
     member = @data.user_by_name params[:user]

     if organization.admins.include? @active_user
       organization.send_request(member)
     end
     flash[:success] = "Added user #{member}"
     redirect back
   end

   post "/organization/:organization/add_admin" do
     organization = @data.organization_by_name(params[:organization])
     member = @data.user_by_name params[:user]

     if organization.admins.include? @active_user
       begin
         organization.add_admin(member)
       rescue TradeException => e
         flash[:error] = e.message
       end
     end
     flash[:success] = "Added user #{member} as admin"
     redirect back
   end

   post "/organization/:organization/remove_admin/:member" do
     organization = @data.organization_by_name(params[:organization])
     member = @data.user_by_name params[:member]

     if organization.admins.include? @active_user
       begin
         organization.remove_admin(member)
       rescue TradeException => e
         flash[:error] = e.message
       end
     end
     flash[:success] = "Removed admin #{member}"
     redirect back
   end

  post "/organization/:organization/accept_request" do
    organization = @data.organization_by_name(params[:organization])
    organization.accept_request @active_user
    flash[:success] = "Accepted request from #{organization.name}"
    redirect back
  end

   post "/organization/:organization/decline_request" do
     organization = @data.organization_by_name(params[:organization])
     organization.decline_request @active_user
     flash[:success] = "Declined request from #{organization.name}"
     redirect back
   end

   get "/user/:user/requests" do
     @title = "Organization requests"
     haml :organization_request
   end

  get "/organizations" do
    @title = "All organizations"
    haml :organizations
  end

  post "/organization/exists" do
    content_type :json
    #explicit true/false necessary for json serialization
    exists = false
    name = OrganizationDataHelper.trim_name(params[:existing])
    if  @data.organization_exists?(name)
      exists = true
    end
    {:exists =>exists }.to_json
  end

end