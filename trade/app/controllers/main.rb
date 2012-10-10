require_relative '../models/item'
require_relative '../models/user'
require 'digest/md5'

class Main  < Sinatra::Application
  #SH Get the user by session
  before do
     @active_user = Models::DataOverlay.instance.user_by_name(session[:name])
  end

  #SH Redirect to the main page
  get "/" do
    redirect "/index"
  end

  #SH Check if logged in and show a list of all active items if true
  get "/index" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::DataOverlay.instance.all_items, :error => nil }
  end

  #SH Shows all items of a user
  get "/user/:name" do
    redirect '/login' unless session[:name]
    user = Models::DataOverlay.instance.user_by_name(params[:name])
    if user.name == @active_user.name
     items = Models::DataOverlay.instance.items_by_user(user)
    else
     items = Models::DataOverlay.instance.active_items_by_user(user)
    end

    haml :user, :locals =>{:user => user, :items => items}
  end

  #SH Buys an item. If an error occurs, redirect to the buy error page
  post "/buy/:item" do
    redirect '/login' unless session[:name]
    item = Models::DataOverlay.instance.item_by_id params[:item].to_i

    if @active_user.buy(item) == "credit error"
      redirect "/index/credit"
    end
    redirect '/index'
  end

  #SH Shows errors caused by buy on the main page
  get "/index/:error" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::DataOverlay.instance.all_items, :error => params[:error] }
  end

  #SH Shows the register form
  get "/register" do
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    if Models::User.passwd_valid?(params[:passwd])
      if params[:passwd]==params[:passwd_repetition]
        if !Models::DataOverlay.instance.user_exists?(params[:username])
        Models::DataOverlay.instance.new_user(params[:username], params[:passwd])
        redirect "/login"
        else
          redirect "/register/user_exists"
        end
      else
        redirect "/register/wrong_repetition"
      end
    else
      redirect "/register/password_invalid"
    end
  end

  #AS sending a message about success to the register view
  get "/register/:message" do
    haml :register, :locals=>{:message => params[:message]}
  end

  #SH Shows a list of all user and their credits
  get "/user" do
    redirect '/login' unless session[:name]
    haml :users, :locals => {:users => Models::User.all}
  end
end