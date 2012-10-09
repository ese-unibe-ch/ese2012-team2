require_relative '../models/user'
class Authentication < Sinatra::Application

  #SH The normal login page
  get "/login" do
    puts settings.public_folder
    haml :login, :locals =>{:error => nil}
  end

  #SH The login page when an error occurred
  get "/login/:error" do
    haml :login , :locals =>{:error => params[:error]}
  end

  #SH Checks whether login was successful and if so, log the user in.
  #SH Otherwise, redirect to the error page
  post "/login" do
    name = params[:username]
    password = params[:password]
    user = Models::User.by_name(name)
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

end