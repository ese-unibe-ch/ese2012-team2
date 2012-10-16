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
          user.set_passwd(new_passwd)
          redirect "change_password/password_changed"
        else
          redirect "change_password/password_invalid"
        end
      else
        redirect "change_password/wrong_repetition"
      end
    else
      redirect "change_password/wrong_password"
    end
  end

  #AS sending a message about success to the view
  get "/change_password/:message" do
    haml :change_password, :locals=>{:message => params[:message]}
  end
end
