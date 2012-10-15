require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative '../helpers/item_validator'
require_relative 'base_controller'

class ItemController < BaseController

  #SH Triggers status of an item
  post "/change/:item" do
    item = @data.item_by_id(params[:item].to_i)

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

    @data.new_item(name, price.to_i, description, @active_user, false, filename)
    redirect "/additem/success"
  end

  #SH Shows a form to add items
  get "/additem" do
    @title = "Add item"
    haml :add_new_item, :locals=>{:message => nil}
  end

  #SH Shows either an error or an success message above the add item form
  get "/additem/:message" do
    @title = "Add item"
    haml :add_new_item, :locals=>{:message => params[:message]}
  end

  post "/delete/:item" do
    item = @data.item_by_id params[:item].to_i
    if item != nil && item.owner == @active_user
      @data.delete_item item
    end
    redirect back
  end

  get "/item/:item" do
    item = @data.item_by_id params[:item].to_i
    @title = "Item " + item.name
    haml :item, :locals => {:item => item}
  end

  get "/item/:item/edit" do
    item = @data.item_by_id params[:item].to_i
    @title = "Edit item " + item.name
    haml :edit_item, :locals => {:item => item, :message => nil}
  end

  post "/item/:item/edit" do
    item = @data.item_by_id params[:item].to_i
    if item.owner == @data.user_by_name(session[:name])
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
      item.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"

    end
    redirect "/user/#{@active_user.name}"
  end

  get "/item/:item/edit/:message" do
    title = "Edit item " + item.name
    haml :edit_item, :locals=>{:item => @data.item_by_id(params[:item].to_i), :message => params[:message]}
  end

end