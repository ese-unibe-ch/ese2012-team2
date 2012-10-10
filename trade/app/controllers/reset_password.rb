require_relative '../models/data_overlay'
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
    user = overlay.user_by_name params[:username]
    redirect "/reset_password/unknown_user" unless user

  end
end