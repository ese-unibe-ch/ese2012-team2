require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative '../helpers/item_validator'
require_relative 'base_secure_controller'

class ItemController < BaseSecureController

  #SH Triggers status of an item
  post "/item/:item/change_state" do
    item = @data.item_by_id(params[:item].to_i)
    item.state = params[:state].to_sym
    redirect back
  end

  #SH Tries to add an item. Redirect to the add item message page.
  post "/add_item" do

    name = params[:name]
    price = params[:price]
    description = params[:description]

    if !ItemValidator.name_empty?(name)
      price = ItemValidator.delete_leading_zeros(price)
      #SH Check if price is an int
      if ItemValidator.price_is_integer?(price)
        if !ItemValidator.price_negative?(price)
          image_name = ImageHelper.save params[:image], "#{settings.public_folder}/images/items"
          @data.new_item(name, price.to_i, description, @active_user, :inactive, image_name)
          add_message("Item added", :success)
        else
          add_message("Price must be positive", :error)
        end
      else
        add_message("Your price is not a number", :error)
      end
    else
      add_message("Invalid item name", :error)
    end
    haml :add_new_item
  end

  #SH Shows a form to add items
  get "/add_item" do
    @title = "Add item"
    haml :add_new_item
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
    haml :edit_item, :locals => {:item => item}
  end

  post "/item/:item/edit" do
    item = @data.item_by_id params[:item].to_i
    if item.owner == @data.user_by_name(session[:name])
      name = params[:name]
      price = params[:price]
      description = params[:description]

      if !ItemValidator.name_empty?(name)
        price = ItemValidator.delete_leading_zeros(price)
        #SH Check if price is an int
        if ItemValidator.price_is_integer?(price)

          if !ItemValidator.price_negative?(price)
            item.name = name
            item.price = price
            item.description = description
            #PS it's nilsafe ;)
            item.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
            add_message("Item edited", :success)
          else
            add_message("Price must be positive", :error)
          end
        else
          add_message("Your price is not a number", :error)
        end
      else
        add_message("Invalid item name", :error)
      end

    end
    haml :edit_item, :locals=>{:item =>item}
  end

end