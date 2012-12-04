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
    @title = "Login"
    haml :login
  end

  #SH Checks whether login was successful and if so, log the user in.
  #SH Otherwise, redirect to the error page
  post "/login" do
    begin
    UserDataHelper.login(params[:username],params[:password])
    session[:name] = params[:username]
    flash[:success] = "Logged in as #{session[:name]}"
    redirect '/index'
    rescue TradeException => e
      flash.now[:error] = e.message
      haml :login
    end
  end

  #SH Logs the user out
  get "/logout" do
    session.clear
    flash[:success] = "Logged out."
    redirect '/login'
  end


  #SH Shows a form to register new user
  get "/register" do
    @title = "Register"
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    begin
    new_user = UserDataHelper.register(params)
    flash[:success] = "Successfully registered user #{new_user.name}."
    redirect '/login'
    rescue TradeException => e
      flash.now[:error] = e.message
    end
    haml :register
  end

  post '/user/exists' do
    content_type :json
    {:exists => @data.user_exists?(params[:existing]) }.to_json
  end
end