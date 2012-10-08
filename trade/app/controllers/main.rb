require 'haml'
require './models/item'
require './models/user'
require 'digest/md5'

class Main  < Sinatra::Application
  #SH Get the user by session
  before do
     @active_user = Models::User.by_name(session[:name])
  end

  #SH Redirect to the main page
  get "/" do
    redirect "/index"
  end

  #SH Check if logged in and show a list of all active items if true
  get "/index" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::Item.all, :error => nil }
  end

  #SH Shows all items of a user
  get "/user/:name" do
    redirect '/login' unless session[:name]
    user = Models::User.by_name(params[:name])
    haml :user, :locals =>{:user => user}
  end

  #SH Buys an item. If an error occurs, redirect to the buy error page
  post "/buy/:item" do
    redirect '/login' unless session[:name]
    item = Models::Item.by_id params[:item].to_i

    if @active_user.buy(item) == "credit error"
      redirect "/index/credit"
    end
    redirect '/index'
  end

  #SH Shows errors caused by buy on the main page
  get "/index/:error" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::Item.all, :error => params[:error] }
  end

  #SH Shows the register form
  get "/register" do
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    Models::User.named(params[:username])
    redirect "/login"
  end

  #SH Shows a list of all user and their credits
  get "/user" do
    redirect '/login' unless session[:name]
    haml :users, :locals => {:users => Models::User.all}
  end
end