require_relative "../models/user"
class ChangePassword < Sinatra::Application

  #AS if not logged in => log in!
  get "/change_password" do
    redirect '/login' unless session[:name]
    haml :change_password, :locals=>{:message => nil}
  end

  #AS attempts to change password
  post "/change_password" do
    new_passwd=params[:new_passwd]
    user= Models::DataOverlay.instance.user_by_name(session[:name])
    user.set_passwd(new_passwd)
    redirect "change_password/password_changed"
  end

  #AS sending a message about success to the view
  get "/change_password/:message" do
    haml :change_password, :locals=>{:message => params[:message]}
  end
end
