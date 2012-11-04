require_relative '../models/trade_exception'

module Models
  #KR This class is responsible for Item & User management. It contains maps holding all items and users
  # and offers useful operations on these maps.
  class DataOverlay

    def initialize
      @users = Hash.new()
      @items = Hash.new()
      @organizations = Hash.new()
      @search_requests= Hash.new() #AS id: user, value: Array of SearchRequests
      @comments = Hash.new() #KR id:owner, value: Array of Comments
      @auctions = Hash.new()
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

    def include?(item)
      if @auctions[item.id] == nil
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
      @items.values.select { |value| value.state == :active }
    end

    def all_items
      @items.values
    end

    #KR returns the user with the given name
    #returns nil if there is no such user
    def user_by_name(name)
      @users[name]
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
  end
end
