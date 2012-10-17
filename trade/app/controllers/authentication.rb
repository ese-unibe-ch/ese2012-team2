require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative 'base_controller'
require_relative '../helpers/user_data_helper'
require_relative '../models/trade_exception'

class Authentication < BaseController

  before do
    @data = Models::DataOverlay.instance
  end

  #SH The normal login page
  get "/login" do
    self.title = "Login"
    haml :login
  end

  #SH Checks whether login was successful and if so, log the user in.
  #SH Otherwise, redirect to the error page
  post "/login" do
    begin
    UserDataHelper.login(params[:username],params[:password])
    session[:name] = params[:username]
    redirect '/index'
    rescue TradeException => e
      add_message(e.message, :error)
      haml :login
    end
  end

  #SH Logs the user out
  get "/logout" do
    session.clear
    redirect '/login'
  end


  #SH Shows a form to register new user
  get "/register" do
    self.title = "Register"
    @title = "Register"
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    begin
    new_user = UserDataHelper.register(params)
    add_message("Successfully registered user #{new_user.name}.", :success)
    rescue TradeException => e
     add_message(e.message, :error)
    end
    haml :register
  end

end