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
    @title = "Add item"
    begin
    ItemValidator.add_item(params, @active_user)
    add_message("Item successfully created!", :success)
    rescue TradeException => e
      add_message(e.message, :error)
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

  post "/item/:item/confirm_buy" do
    item = @data.item_by_id params[:item].to_i
    @active_user.confirm_receipt item
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
    @title = "Edit item " + item.name
    if item.owner == @data.user_by_name(session[:name])
      begin
      name = params[:name]
      price = params[:price]
      description = params[:description]

      p = Models::Item.validate_price(price)
      if name.empty?
         add_message("Item name must not be empty!", :error)
      else
        item.name = name
        item.price = p
        item.description = description
        #PS it's nilsafe ;)
        item.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
        Event::ItemUpdateEvent.item_changed item
        add_message("Item edited!", :success)
      end
      rescue TradeException => e
      add_message(e.message, :error)
    end
    end
    haml :edit_item, :locals=>{:item =>item}
  end

  post "/item/:id/transfer/:organization" do
    item = @data.item_by_id params[:id].to_i
    organization = @data.organization_by_name params[:organization]
    item.take_ownership(organization)
    redirect back
  end

end