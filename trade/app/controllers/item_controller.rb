require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative '../helpers/item_validator'

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

    if ItemValidator.name_empty?(name)
      redirect "/additem/invalid_item"
    end

    price = ItemValidator.delete_leading_zeros(price)

    #SH Check if price is an int
    unless ItemValidator.price_is_integer?(price)
      redirect "/additem/invalid_price"
    end

    if ItemValidator.price_negative?(price)
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
    item = Models::DataOverlay.instance.item_by_id params[:item].to_i
    if item != nil && item.owner == @active_user
      Models::DataOverlay.instance.delete_item item
    end
    redirect back
  end

  get "/item/:item" do
    redirect '/login' unless session[:name]
    item = Models::DataOverlay.instance.item_by_id params[:item].to_i
    haml :item, :locals => {:item => item}
  end

  get "/item/:item/edit" do
    item = Models::Item.by_id params[:item].to_i

    haml :edit_item, :locals => {:item => item, :message => nil}

  end

  post "/item/:item/edit" do
    item = Models::DataOverlay.instance.item_by_id params[:item].to_i
    if item.owner == Models::DataOverlay.instance.user_by_name(session[:name])
      name = params[:name]
      price = params[:price]
      description = params[:description]

      if ItemValidator.name_empty?(name)
        redirect "/item/#{item.id}/edit/invalid_item"
      end

      price = ItemValidator.delete_leading_zeros(price)

      #SH Check if price is an int
      unless ItemValidator.price_is_integer?(price)
        redirect "/item/#{item.id}/edit/invalid_price"
      end

      if ItemValidator.price_negative?(price)
        redirect "/item/#{item.id}/edit/negative_price"
      end

      item.name = name
      item.price = price
      item.description = description
      #PS it's nilsafe ;)
      item.image = ImageHelper.save params[:image], settings.public_folder

    end
    redirect "/user/#{@active_user.name}"
  end

  get "/item/:item/edit/:message" do
    haml :edit_item, :locals=>{:item => Models::DataOverlay.instance.item_by_id(params[:item].to_i), :message => params[:message]}
  end

end