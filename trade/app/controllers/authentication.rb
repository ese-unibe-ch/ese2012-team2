require 'haml'
require './models/user'
class Authentication < Sinatra::Application

  get "/login" do
    haml :login, :locals =>{:error => nil}
  end

  get "/login/:error" do
    haml :login , :locals =>{:error => params[:error]}
  end

  post "/login" do
    name = params[:username]
    password = params[:password]



      user = Models::User.by_name(name)
      if user.nil? || password != name
        redirect '/login/wrong'
      else
        session[:name] = name
        redirect '/'
      end

  end

  get "/logout" do
    session[:name] = nil
    redirect '/login'
  end

end