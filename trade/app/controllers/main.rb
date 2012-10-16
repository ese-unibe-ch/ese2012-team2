require_relative '../models/item'
require_relative '../models/user'
require 'digest/md5'
require_relative 'base_controller'
require_relative '../helpers/user_data_helper'

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
    haml :edit_user, :locals=>{:message=>nil}
  end

  post "/user/:user/edit" do
    display_name = params[:display_name]

    display_name = UserDataHelper.remove_white_spaces(display_name)

    if @data.user_display_name_exists?(display_name) and display_name != @active_user.displayname
      redirect "/user/#{@active_user.name}/edit/user_exists"
    else
      @active_user.displayname = display_name
    #TODO edit image
      @active_user.interests = params[:interests]
    end
    redirect "/user/#{@active_user.name}"
  end

  get "/user/:user/edit/:message" do
    haml :edit_user, :locals=>{:message=>params[:message]}
  end

end