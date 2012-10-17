require_relative '../models/user'
require_relative 'base_secure_controller'

class ChangePassword < BaseSecureController

  #AS if not logged in => log in!
  get "/change_password" do
    haml :change_password, :locals=>{:message => nil}
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
          add_message("Your password was changed.", :success)
        else
          add_message("Your password is not invalid. Password must be at least 8 characters and contain upper- and lowercase characters as well as at least one number.", :error)
        end
      else
        add_message("The password repetition and the new password have to be identical.", :error)
      end
    else
      add_message("You entered the wrong password.", :error)
    end
    haml :change_password
  end

  #AS sending a message about success to the view
  get "/change_password/:message" do
    haml :change_password, :locals=>{:message => params[:message]}
  end
end
