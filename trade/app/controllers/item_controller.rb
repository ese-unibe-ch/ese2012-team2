require_relative '../models/user'
require_relative '../helpers/image_helper'
require_relative '../helpers/item_validator'
require_relative 'base_secure_controller'
require_relative '../models/auction'
require_relative '../models/tag'

class ItemController < BaseSecureController

  #SH Triggers status of an item
  post "/item/:item/change_state" do
    item = @data.item_by_id(params[:item].to_i)
    item.state = params[:state].to_sym
    flash[:success] = "Set item #{item.name} to #{item.state.to_s}"
    redirect back
  end

  #SH Tries to add an item. Redirect to the add item message page.
  post "/add_item" do
    @title = "Add item"
    as_request= params[:action]=="Add as a request"

    begin
    ItemValidator.add_item(params, @active_user, as_request)
    flash.now[:success] =  "Item successfully created! You can activate the item in your <a href = '/all_items/#{@active_user.name}'>item list</a>."
    rescue TradeException => e
      flash.now[:error] = e.message
    end
    haml :add_new_item
  end

  #SH Shows a form to add items
  get "/add_item" do
    @title = "Add item"
    haml :add_new_item
  end

  # deletes an item and auction
  post "/delete/:item" do
    item = @data.item_by_id params[:item].to_i
    auction = @data.auction_by_id(item.id)

    if auction != nil
      @data.delete_auction(auction)
    end

    if item != nil && item.owner == @active_user
      @data.delete_item item
    end
    flash[:success] = "Deleted item #{item.name}"
    redirect back
  end

  # confirms the buy
  post "/item/:item/confirm_buy" do
    item = @data.item_by_id params[:item].to_i
    puts item.prev_owners.length
    puts item.name
    @active_user.confirm_receipt item
    redirect back
  end

  # save information to create new auction
  post "/item/:item/show_auction_adding" do
    item = @data.item_by_id params[:item].to_i
    @title = "Edit item " + item.name
    success = false
    begin
      if item.owner == @data.user_by_name(session[:name]) or item.owner == @active_user.working_for
        minimal = params[:minimal]
        increment = params[:increment]
        p = Models::Auction.validate_minimal(minimal)
        i = Models::Auction.validate_increment(increment)
        Models::Auction.new(@active_user, item, params)
        flash.now[:success] = "Successfully added an auction"
        success = true
      end
    rescue TradeException => e
      flash.now[:error] = e.message
    end
    if success or item.state == :active or item.state == :auction
      haml :list_auctions, :locals => {:auctions => @data.all_auctions}
    else
      haml :add_for_auction, :locals => {:item => item, :time_now => Time.now}
    end
  end

  # get page to create new auction
  get "/item/:item/for_auction" do
    @title = "Add Item For Auction"
    item = @data.item_by_id params[:item].to_i
    auction = @data.auction_by_id params[:item].to_i

    haml :add_for_auction, :locals => {:item => item, :auction => auction, :time_now => Time.now}
  end

  # show all active auctions
  get "/auctions" do
    @title = "All auctions"
    haml :list_auctions, :locals => {:auctions => @data.all_auctions}
  end

  # show the chosen auction
  get "/auction/:auction" do
    @title = "Chosen Auction"
    auction = @data.auction_by_id params[:auction].to_i
    if auction == nil
      redirect "/item/auction"
    end
    haml :show_auction, :locals => { :auction => auction}
  end

  # set a bid to an auction
  post "/auction/:auction/set_bid" do
    @title = "Set Bid"
    begin
      auction = @data.auction_by_id params[:auction].to_i
      if auction == nil
        redirect "/item/auction"
      end
      bid = Models::Item.validate_price(params[:bid])
      @active_user.give_bid(auction, bid)
      flash.now[:success] = "Bid successful!"
    rescue TradeException => e
      flash.now[:error] = e.message
    end

    haml :show_auction, :locals => { :auction => auction}
  end

  # set item back to selling mode
  get "/auction/go_back_to_selling_mode/:item" do
    item = @data.item_by_id params[:item].to_i
    auction = @data.auction_by_id(item.id)
    @data.delete_auction(auction)
    item.state = :inactive

    redirect "/user/#{@active_user.name}"
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
    if item.owner == @data.user_by_name(session[:name]) or item.owner == @active_user.working_for
      begin
      name = params[:name]
      price = params[:price]
      description = params[:description]
      end_time = ItemValidator.parse_date_time(params[:date],params[:time])


      p = Models::Item.validate_price(price)
      quantity = Models::Item.validate_quantity(params[:quantity])
      if name.empty?
        flash.now[:error] = "Item name must not be empty!"
      else
        item.name = name
        item.price = p
        item.quantity = quantity
        item.description = description
        #PS it's nil safe ;)
        item.end_time = end_time
        item.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
        Event::ItemUpdateEvent.item_changed item
        tags = params[:tags]
        item.remove_all_tags
        unless tags.nil?
          for tag in tags
            t = Models::Tag.get_tag(tag)
            item.add_tag(t)
          end
        end
        flash.now[:success] = "Edited item #{item.name}!"
       end
      rescue TradeException => e
        flash.now[:error] = e.message
    end
    end
    haml :edit_item, :locals=>{:item =>item}
  end

  post "/item/:id/transfer/:organization" do
    item = @data.item_by_id params[:id].to_i
    organization = @data.organization_by_name params[:organization]
    item.take_ownership(organization)
    flash[:success] =  "Transferred item #{item.name} to #{organization.name}"
    redirect back
  end

  post "/item/:id/wish" do
    item = @data.item_by_id params[:id].to_i
    @active_user.add_wish item
    flash[:success] =  "Added item #{item.name} to wishlist"
    redirect "/user/#{@active_user.name}"
  end

  post "/item/:id/remove_wish" do
    item = @data.item_by_id params[:id].to_i
    @active_user.remove_wish item
    flash[:success] =  "Removed item #{item.name} from wishlist"
    redirect "/user/#{@active_user.name}"
  end

  get "/item/:id/description/:desc_id" do
    item = @data.item_by_id params[:id].to_i
    description = item.descriptions[params[:desc_id].to_i]
    haml :'partials/description', :layout => :'ajax_layout', :locals => {:description => description}
  end

  get "/tags/all" do
    content_type :json
    {:tags => @data.all_tags }.to_json
  end

end