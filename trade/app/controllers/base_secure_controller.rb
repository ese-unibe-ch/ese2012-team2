require_relative 'base_controller'

class BaseSecureController < BaseController

  attr_accessor :active_user

  before do
    #redirect to login
    redirect '/login' unless session[:name]
    #set current user
    @data = Models::DataOverlay.instance
    @active_user = @data.user_by_name(session[:name])
    if session[:working_for]
      @active_user.working_for = @data.organization_by_name(session[:working_for])
    end
    @title = ""
  end
end