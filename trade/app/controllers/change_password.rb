require_relative '../models/user'
require_relative 'base_secure_controller'

class ChangePassword < BaseSecureController

  #AS if not logged in => log in!
  get "/change_password" do
    @title = "Change Password"
    haml :change_password
  end

  #AS attempts to change password
  post "/change_password" do
    user = @data.user_by_name(session[:name])
    passwd = params[:passwd]
    if user.authenticated?(passwd)
      new_passwd = params[:new_passwd]
      passwd_repetition=params[:passwd_repetition]
      if new_passwd == passwd_repetition
        if Models::User.passwd_valid?(new_passwd)
          user.password = Models::Password.make(new_passwd)
          flash.now[:success] = "Your password was changed."
         else
          flash.now[:error] = "Your password is not invalid. Password must be at least 8 characters and contain upper- and lowercase characters as well as at least one number."
        end
      else
        flash.now[:error] = "The password repetition and the new password have to be identical."
      end
    else
      flash.now[:error] = "You entered the wrong password."
    end
    haml :change_password
  end
end
