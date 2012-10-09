require_relative '../models/user'
require_relative '../helpers/image_helper'

class ItemController < Sinatra::Application

  #SH Get the user by session
  before do
    @active_user = Models::DataOverlay.instance.user_by_name(session[:name])
  end

  #SH Triggers status of an item
  post "/change/:item" do
    redirect '/login' unless session[:name]
    item = Models::DataOverlay.instance.item_by_id(params[:item].to_i)

    if params[:action] == "Activate" && item.owner == @active_user
      item.active = true
    end

    if params[:action] == "Deactivate" && item.owner == @active_user
      item.active = false
    end

    redirect back
  end

  #SH Tries to add an item. Redirect to the additem message page.
  post "/additem" do
    redirect '/login' unless session[:name]

    name = params[:name]
    price = params[:price]
    description = params[:description]

    if name == ""
      redirect "/additem/invalid_item"
    end

    #SH Removing heading zeros because these would make the int oct
    while price.start_with?("0") and price.length > 1
      price.slice!(0)
    end

    #SH Check if price is an int
    unless price.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
      redirect "/additem/invalid_price"
    end

    if price.to_i < 0
      redirect "/additem/negative_price"
    end

    filename = ImageHelper.save params[:image], settings.public_folder

    Models::DataOverlay.instance.new_item(name, price.to_i, description, @active_user, false, filename)
    redirect "/additem/success"
  end

  #SH Shows a form to add items
  get "/additem" do
    redirect '/login' unless session[:name]
    haml :add_new_item, :locals=>{:message => nil}
  end

  #SH Shows either an error or an success message above the add item form
  get "/additem/:message" do
    haml :add_new_item, :locals=>{:message => params[:message]}
  end

  post "/delete/:item" do
    item = Models::ItemController.by_id params[:item].to_i
    if item != nil && item.owner == @active_user
      Models::ItemController.delete_item item
    end
    redirect back
  end

  get "/item/:item" do
    redirect '/login' unless session[:name]
    item = Models::ItemController.by_id params[:item].to_i
    haml :item, :locals => {:item => item}
  end

  post "/item/:item/edit" do
    item = Models::ItemController.by_id params[:item].to_i
    name = params[item.name]
    price = params[item.price]
    description = params[item.description]

    haml :edit_item, :locals => {:name => name, :price => price, :description => description}

  end
end