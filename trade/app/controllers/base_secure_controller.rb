require_relative 'base_controller'

class BaseSecureController < BaseController

  attr_accessor :active_user

  before do
    #redirect to login
    redirect '/login' unless session[:name]
    #set current user
    @data = Models::DataOverlay.instance
    @active_user = @data.user_by_name(session[:name])
    @title = ""
  end
end