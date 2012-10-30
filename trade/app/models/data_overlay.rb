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

    def new_item(name, price, description, owner, state=:inactive, image=nil)
      item = Item.named name, price, owner, description, image
      item.state = state
      add_item item
      return item
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
      result = Array.new
      @items.each_value {
          |value|
        if (value.owner==trader and value.state == :active)
          result.push value
        end
      }
      return result
    end

    #KR returns all active items
    def active_items
      result = Array.new
      @items.each_value {
          |value|
        if (value.active)
          result.push value
        end
      }
      return result
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

    #PS all objects are true except nil & false ;)
    def user_display_name_exists?(display_name)
      @users.values.detect { |user| user.display_name == display_name }
    end


    #AS checks if a user exists
    def user_exists?(name)
      @users.member?(name)
    end

    #KR adds a new user to the environment
    # if name or id are already in use, this function raises an error
    def add_user(user)
      if (@users.has_key?(user.name))
        #raise error here
      end
      @users[user.name] = user
    end

    def new_user(name, display_name, pw, email, interests)
      user = User.named(name, display_name, pw, email, interests)
      add_user user
      return user
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

    #SH adds a new organization to the environment
    # if name or id are already in use, this function raises an error
    def add_organization(organization)
      if @organizations.has_key?(organization.name)
        #raise error here
      end
      @organizations[organization.name] = organization
    end

    def new_organization(name, interests, admin)
      organization = Organization.named(name, interests, admin)
      add_organization organization
      organization
    end

    #AS Create a new search request and add it.
    def new_search_request(keywords, user)
      search_request= SearchRequest.create(keywords, user)
      add_search_request search_request
      search_request
    end

    #AS Get the organizations which a user is part of
    def organizations_by_user(user)
      result= Array.new(@organizations.values)
      result.delete_if { |org| !org.is_member?(user) }
      result
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
