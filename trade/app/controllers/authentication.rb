require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative 'base_controller'

class Authentication < Sinatra::Application

  before do
    @data = Models::DataOverlay.instance
  end

  #SH The normal login page
  get "/login" do
    @title = "Login"
    haml :login, :locals =>{:error => nil}
  end

  #SH The login page when an error occurred
  get "/login/:error" do
    @title = "Login"
    haml :login , :locals =>{:error => params[:error]}
  end

  #SH Checks whether login was successful and if so, log the user in.
  #SH Otherwise, redirect to the error page
  post "/login" do
    name = params[:username]
    password = params[:password]
    user = @data.user_by_name name
    if user.nil? || !user.authenticated?(password)
      redirect '/login/wrong'
    else
      session[:name] = name
      redirect '/'
    end

  end

  #SH Logs the user out
  get "/logout" do
    session[:name] = nil
    redirect '/login'
  end


  #SH Shows a form to register new user
  get "/register" do
    @title = "Register"
    haml :register, :locals => {:message => nil}
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    if Models::User.passwd_valid?(params[:passwd])
      if params[:passwd]==params[:passwd_repetition]
        unless @data.user_exists?(params[:username])
          @data.new_user(params[:username], params[:passwd])
          redirect "/login"
        else
          redirect "/register/user_exists"
        end
      else
        redirect "/register/wrong_repetition"
      end
    else
      redirect "/register/password_invalid"
    end
  end

  #AS sending a message about success to the register view
  get "/register/:message" do
    @title = "Register"
    haml :register, :locals=>{:message => params[:message]}
  end

  get "/user/:user/edit" do
    name = params[:username]
    user = @data.user_by_name name
    haml :edit_user, :locals=>{:user=>user, :message=>nil}
  end

  post "/user/:user/edit" do
    name = params[:username]
    user = @data.user_by_name name

    if @data.user_exists?(params[:username])
      redirect "/register/user_exists"
    else
      user.name = name
      user.image = ImageHelper.save params[:image], settings.public_folder
    end
    redirect back
  end

  get "/user/:user/edit/:message" do
    name = params[:username]
    user = @data.user_by_name name
    haml :edit_user, :locals=>{:user=>user, :message=>params[:message]}
  end

end