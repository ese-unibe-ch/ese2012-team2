require_relative '../models/data_overlay'
require_relative '../helpers/email_sender'
class ResetPassword  < Sinatra::Application
  before  do
     @overlay = Models::DataOverlay.instance
  end

  get "/reset_password" do
    redirect '/user' if session[:name] #KR if user is already logged in, send him to his profile
    haml :reset_password
  end

  post "/reset_password" do
    redirect '/user' if session[:name]
    user = @overlay.user_by_name params[:username]
    redirect "/reset_password/unknown_user" unless user
    pw='yourNewPassword' #TODO KR replace static pw with generation method
    user.set_passwd pw
    EmailSender.send_new_password(user, pw)
    redirect '/login'
  end
end