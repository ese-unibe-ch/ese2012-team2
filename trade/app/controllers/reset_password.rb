require_relative '../models/data_overlay'
require_relative '../helpers/email_sender'
class ResetPassword  < Sinatra::Application
  before  do
     @overlay = Models::DataOverlay.instance
  end

  get "/reset_password" do
    redirect '/user' if session[:name] #KR if user is already logged in, send him to his profile
    haml :reset_password, :locals => {:message => nil}
  end

  post "/reset_password" do
    redirect '/user' if session[:name]
    user = @overlay.user_by_name params[:username]
    redirect "/reset_password/#{params[:username]}" unless user
    pw= ResetPassword.random_password
    user.set_passwd pw
    EmailSender.send_new_password(user, pw)
    redirect '/login'
  end

  get "/reset_password/:unknown_user" do
    redirect 'user' if session[:name]
    haml :reset_password, :locals => {:message => "#{params[:unknown_user]} was not found"}
  end

  def self.random_password(size = 8)
    pool = ('a'..'z').to_a + ('0'..'9').to_a
    (1..size).collect{|a| pool[rand(pool.size)]}.join
  end
end