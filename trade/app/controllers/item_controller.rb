require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative '../helpers/item_validator'
require_relative 'base_secure_controller'
require_relative '../models/auction'

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
    auction = @data.auction_by_id(item.id)

    if auction =! nil
      @data.delete_auction(auction)
    end

    if item != nil && item.owner == @active_user
      @data.delete_item item
    end

    redirect back
  end

  post "/item/:item/confirm_buy" do
    item = @data.item_by_id params[:item].to_i
    puts item.prev_owners.length
    puts item.name
    @active_user.confirm_receipt item
    redirect back
  end

  #----------------------------------------

  post "/item/:item/show_auction_adding" do
    item = @data.item_by_id params[:item].to_i
    @title = "Edit item " + item.name
    if item.owner == @data.user_by_name(session[:name]) or item.owner == @active_user.working_for
      name = params[:name]
      price = params[:minimal]
      p = Models::Item.validate_price(price)
      Models::Auction.new(@active_user, item, params)
    end
    redirect "/item/auction"
  end

  get "/item/:item/for_auction" do
    item = @data.item_by_id params[:item].to_i
    @title = "Add Item For Auction"
    haml :add_for_auction, :locals => {:item => item, :time_now => Time.now}
  end

  get "/item/auction" do
    @title = "All auctions"
    haml :list_auctions, :locals => {:auctions => @data.all_auctions}
  end

  get "/auction/:auction" do
    @title = "Chosen Auction"
    auction = @data.auction_by_id params[:auction].to_i
    haml :show_auction, :locals => { :auction => auction}
  end

  post "/auction/:auction/set_bid" do
    @title = "Set Bid"
    begin
      auction = @data.auction_by_id params[:auction].to_i
      bid = Models::Item.validate_price(params[:bid])
      @active_user.give_bid(auction, bid)
      add_message("Bid successful!", :success)
    rescue TradeException => e
      add_message(e.message, :error)
    end

    #if @active_user =! auction.user

    #else add_message("Can not bid for own Item", :error)
    #end
    haml :show_auction, :locals => { :auction => auction}
  end

  #-------------------------------

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
    if item.owner == @data.user_by_name(session[:name]) or item.owner == @active_user.working_for
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

  post "/item/:id/wish" do
    item = @data.item_by_id params[:id].to_i
    @active_user.wish_list << item
    redirect "/user/#{@active_user.name}"
  end

  post "/item/:id/remove_wish" do
    item = @data.item_by_id params[:id].to_i
    @active_user.remove_wish item
    redirect "/user/#{@active_user.name}"
  end

end