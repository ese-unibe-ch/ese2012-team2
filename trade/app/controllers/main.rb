require_relative '../models/item'
require_relative '../models/user'
require 'digest/md5'
require_relative 'base_controller'

class Main  < BaseController

  #SH Redirect to the main page
  get "/" do
    redirect "/index"
  end

  #SH Check if logged in and show a list of all active items if true
  get "/index" do
    @title = "Home"
    haml :index, :locals => {:current_name => session[:name], :items => @data.all_items, :error => nil }
  end

  #SH Shows all items of a user
  get "/user/:name" do
    @title = "User " + params[:name]
    user = @data.user_by_name(params[:name])
    if user.name == @active_user.name
     items = @data.items_by_user(user)
    else
     items = @data.active_items_by_user(user)
    end

    haml :user, :locals =>{:user => user, :items => items}
  end

  #SH Buys an item. If an error occurs, redirect to the buy error page
  post "/buy/:item" do
    item = @data.item_by_id params[:item].to_i

    if @active_user.buy(item) == "credit error"
      redirect "/index/credit"
    end
    redirect '/index'
  end

  #SH Shows errors caused by buy on the main page
  get "/index/:error" do
    @title = "Home"
    haml :index, :locals => {:current_name => session[:name], :items => @data.all_items, :error => params[:error] }
  end

  #SH Shows a list of all user and their credits
  get "/user" do
    @title = "All users"
    haml :users, :locals => {:users => Models::User.all}
  end

  get "/user/:user/edit" do
    name = params[:username]
    user = @data.user_by_name name
    haml :edit_user, :locals=>{:user=>user, :message=>nil}
  end

  post "/user/:user/edit" do
    name = params[:username]
    user = @data.user_by_name name

    if @data.user_exists?(params[:username])
      redirect "/register/user_exists"
    else
      user.name = name
      user.image = ImageHelper.save params[:image], settings.public_folder
    end
    redirect back
  end

  get "/user/:user/edit/:message" do
    name = params[:username]
    user = @data.user_by_name name
    haml :edit_user, :locals=>{:user=>user, :message=>params[:message]}
  end

end