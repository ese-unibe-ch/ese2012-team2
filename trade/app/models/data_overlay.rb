require_relative '../models/trade_exception'
require_relative 'similar_item_request'

module Models
  #KR This class is responsible for Item & User management. It contains maps holding all items and users
  # and offers useful operations on these maps.
  class DataOverlay

    def initialize
      @users = Hash.new()
      @items = Hash.new()
      @activities = Array.new()
      @trackees = Hash.new(Array.new) #PS is: User, value Array of Trackables
      @organizations = Hash.new()
      @search_requests= Hash.new()
      @comments = Hash.new() #KR id:owner, value: Array of Comments
      @auctions = Hash.new()
      @item_requests= Hash.new()
      @tags= Hash.new() #AS id: name of the tag, value: the tag
    end

    @@instance = nil

    #KR returns the DataOverlay instance for this Application
    # The instance is singleton so it stays the same at every point in runtime
    # on the first call the instance is constructed
    def self.instance
      if (@@instance == nil)
        @@instance = DataOverlay.new
      end
      return @@instance
    end

    def add_auction(auction)
      @auctions[auction.id] = auction
    end

    def delete_auction(auction)
      @auctions.delete auction.id
    end

    def all_auctions
      @auctions.values
    end

    def auction_by_id(id)
      @auctions[id]
    end

    def include?(id)
      if @auctions[id] == nil
        return false
      else return true
      end
    end

    #KR adds a new item to the environment.
    # if the id is already in use, raises an error
    def add_item(item)
      if (@items.has_key?(item.id))
        #raise error here
      end
      @items[item.id] = item
      Event::ItemUpdateEvent.item_created item
    end

    def delete_item(item)
      item.owner.add_activity "has deleted item #{item.name}"
      @items.delete item.id
    end

    #KR returns the item corresponding to the id
    # returns nil if there is no such item
    def item_by_id(id)
      @items[id]
    end

    #KR returns all items currently owned by the given user
    #if the user is not in the user list, an error will be raised
    def items_by_trader(trader)
      @items.values.select { |value| value.owner==trader }
    end

    def active_items_by_trader(trader)
      @items.values.select { |value| value.owner==trader and value.state == :active }
    end

    #KR returns all active items
    def active_items
      @items.values.select { |value| value.state == :active || value.state == :auction}
    end

    def all_items
      @items.values
    end


    def active_items_by_name_and_user(name,user)
     @items.values.select{|item| item.name==name and item.state==:active and item.owner==user}
    end

    #KR returns the user with the given name
    #returns nil if there is no such user
    def user_by_name(name)
      @users[name]
    end
    def delete_user(user)
      @users.delete user.name
    end

    def all_users
      @users.values
    end

    def pending_items_by_user user
      @items.values.select { |item| item.state == :pending and item.prev_owners.last == user }
    end

    #PS all objects are true except nil & false ;)
    def user_display_name_exists?(display_name)
      @users.values.detect { |user| user.display_name == display_name }
    end

    #AS checks if a user exists
    def user_exists?(name)
      @users.member?(name)
    end

    #KR adds a new user to the environment
    def add_user(user)
      @users[user.name] = user
    end

    #SH returns the organization with the given name
    #returns nil if there is no such user
    def organization_by_name(name)
      @organizations[name]
    end

    def all_organizations
      @organizations.values
    end

    #SH checks if a organization exists
    def organization_exists?(name)
      @organizations.member?(name)
    end

    def add_organization(organization)
      @organizations[organization.name] = organization
    end

    #AS Create a new search request and add it.
    def new_search_request(keywords, user)
      search_request= SearchRequest.create(keywords, user)
      add_search_request search_request
      search_request
    end

    #AS Get the organizations which a user is part of
    def organizations_by_user(user)
      @organizations.values.select { |org| org.is_member?(user) }
    end

    #AS Add a new SearchRequest
    def add_search_request(search_request)
      if (@search_requests.has_key?(search_request.id))
        #error
      else
        @search_requests[search_request.id]= search_request
        Event::ItemUpdateEvent.add_handler search_request
      end
    end

    #AS List SearchRequests of a user
    def search_requests_by_user(user)
      result= Array.new(@search_requests.values)
      result.delete_if { |search_request| search_request.user != user }
      result
    end

    #AS Remove a SearchRequest
    def remove_search_request(search_request_to_delete)
      @search_requests.delete(search_request_to_delete.id)
      Event::ItemUpdateEvent.remove_handler search_request_to_delete
    end

    #AS Get SearchRequest by id
    def search_request_by_id(id)
      @search_requests[id]
    end

    #KR adds a new activity to the system
    def add_activity(activity)
      @activities.push activity
    end

    #KR returns all activities of a the specified owner.
    def activities_by_owner(owner)
      acts = @activities.select { |act| act.owner == owner}
      unless acts.nil?
        self.sort_activities acts
      end
    end

    #PS owner is an Array of Trackable
    def activities_by_owners(owners)
      acts = @activities.select { |act| owners.include? act.owner}
      unless acts.nil?
        self.sort_activities acts
      end
    end

    def sort_activities activities
      activities.sort { |a,b| b.date <=> a.date }
    end

    def remove_by_owner(owner)
       @activities.delete_if { |act| act.owner == owner}
    end

    #tracking items, users and organizations

    def track(tracker,trackee)
       if @trackees.has_key? tracker
         unless @trackees[tracker].include? trackee
           @trackees[tracker].push trackee
         end
       else
         @trackees[tracker] = [trackee]
       end
    end

    def untrack(tracker,trackee)
      if @trackees.has_key? tracker
        @trackees[tracker].delete trackee
      end
    end

    def trackee_by_tracker_and_id(tracker,track_id)
       @trackees[tracker].detect { |tr| tr.track_id == track_id}
    end

    def trackees_by_user(user)
      @trackees[user]
    end

    def remove_trackers_by_trackee(trackee)
      @trackees.each{|key, value| value.delete trackee}
    end

    #AS Add a request for an item - eg. add an item to item_requests
    def add_item_request(item)
      if(@item_requests.has_key?(item.id))
        #error
      else
        @item_requests[item.id]=item
      end
    end

    #AS Get array of item req
    def get_item_requests()
      @item_requests.values
    end
    def get_item_request_by_id(id)
      @item_requests[id]
    end

    def delete_item_request(request_id)
      @item_requests.delete(request_id)
    end


    def add_tag(tag)
        if(@tags.has_key?(tag.name))
          #error
        else
          @tags[tag.name]=tag
        end
    end

    def all_tags
      @tags.keys.collect { |key| key.gsub("#", "")}
    end

    def get_tag(name)
      @tags[name]
    end

    def tags_by_item(item)
      @tags.values.select { |tag| tag.matches.include?(item) }
    end

    def remove_all_tags_from_item(item)
      for tag in @tags.values do
        tag.matches.delete(item)
      end
    end

    def get_tags
      @tags.values
    end

    def similar_items(item)
      similar_item_request = Models::SimilarItemRequest.new(item)
      self.all_items.select{|it| similar_item_request.applies?(it)}
      #similar_items.sort { |a,b| b.hits <=> a.hits }
    end
  end
end
