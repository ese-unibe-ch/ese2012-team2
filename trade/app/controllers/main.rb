require_relative '../models/item'
require_relative '../models/user'
require_relative '../models/search_request'
require 'digest/md5'
require_relative 'base_secure_controller'
require_relative '../helpers/user_data_helper'
require_relative '../helpers/image_helper'

class Main  < BaseSecureController

  attr_accessor :items

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
      add_message("Not enough credits", :error)
    end
    redirect "/index"
  end


  #SH Shows a list of all user and their credits
  get "/user" do
    @title = "All users"
    haml :users, :locals => {:users => @data.all_users}
  end

  get "/user/:user/edit" do
    @title = "Edit user " + params[:user]
    haml :edit_user
  end

  post "/user/:user/edit" do
    display_name = params[:display_name]

    display_name = UserDataHelper.remove_white_spaces(display_name)

    if @data.user_display_name_exists?(display_name) and display_name != @active_user.display_name
      add_message("Name already exists.", :error)
      haml :edit_user
    else
      @active_user.display_name = display_name
      @active_user.image = ImageHelper.save(params[:image], "#{settings.public_folder}/images/users")
      @active_user.interests = params[:interests]
      redirect "/user/#{@active_user.name}"
    end
  end

  post "/search" do
    keyword = Models::SearchRequest.splitUp(params[:keywords])
    search_request = Models::SearchRequest.create(keyword, @active_user)
    items = search_request.get_matching_items(@data.all_items)
    haml :search, :locals => {:search_request => search_request, :items => items}
  end

  get "/search_requests" do
    search_requests = @data.search_requests_by_user(@active_user)
    haml :search_requests, :locals => {:search_requests => search_requests}
  end

  get "/delete/:search_request" do
    search_request = @data.search_request_by_id params[:search_request].to_i
    if search_request != nil && search_request.user == @active_user
      @data.remove_search_request(search_request)
    end
    redirect back
  end

  post "/research/:search_request" do
    search_request = @data.search_request_by_id params[:search_request].to_i
    keyword = Models::SearchRequest.splitUp(search_request.keywords)
    search_request = Models::SearchRequest.create(keyword, @active_user)
    items = search_request.get_matching_items(@data.all_items)
    haml :search, :locals => {:search_request => search_request, :items => items}
  end

  post "/subscribe" do
    @data.new_search_request(params[:keywords], @active_user)
    add_message("Successfully subscribed.", :success)
    redirect "/search_requests"
  end
end
