require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative 'base_controller'
require_relative '../helpers/user_data_helper'

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
    rescue Exception => e
      add_message(e.message, :error)
      haml :login
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
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    if Models::User.passwd_valid?(params[:passwd])
      if params[:passwd]==params[:passwd_repetition]
        unless @data.user_exists?(params[:username])
          display_name = params[:display_name]
          display_name = UserDataHelper.remove_white_spaces(display_name)
          if params[:username] == "" || params[:display_name] == "" || params[:passwd] == "" || params[:email] == ""
            add_message("Data are missing.", :error)
          else if @data.user_display_name_exists?(display_name)
            add_message("Display name already exists.", :error)
          end
            if !UserDataHelper.right_email?(params[:email])
              add_message("Incorrect email address.", :error)
            end
          end
          new_user = @data.new_user(params[:username], display_name, params[:passwd], params[:email], params[:interests])
          new_user.image = ImageHelper.save(params[:image],"#{settings.public_folder}/images/users")
          add_message("Successful registered.", :success)
        else
          add_message("User already exists.", :error)
        end
      else
        add_message("Password and password repetition have to be identical.", :error)
      end
    else
      add_message("Your password is invalid.", :error)
    end
    haml :register
  end

end