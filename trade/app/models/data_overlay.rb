require_relative '../models/trade_exception'

module Models
  #KR This class is responsible for Item & User management. It contains maps holding all items and users
  # and offers useful operations on these maps.
  class DataOverlay

    def initialize
      @users = Hash.new()
      @items = Hash.new()
      @search_requests= Hash.new() #AS id: user, value: Array of SearchRequests
    end

    @@instance = nil

    #KR returns the DataOverlay instance for this Application
    # The instance is singleton so it stays the same at every point in runtime
    # on the first call the instance is constructed
    def self.instance
      if(@@instance == nil)
        @@instance = DataOverlay.new
      end
      return @@instance
    end

    #@users = nil
    #@items = nil

    #KR adds a new item to the environment.
    # if the id is already in use, raises an error
    def add_item(item)
      if(@items.has_key?(item.id))
        #raise error here
      end
      @items[item.id] = item
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
    def items_by_user(user)
      result = Array.new
      @items.each_value {
          |value|
        if(value.owner==user)
         result.push value
        end
      }
      return result
    end

    def active_items_by_user(user)
      result = Array.new
      @items.each_value {
          |value|
        if(value.owner==user and value.active)
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
        if(value.active)
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

    #AS checks if a user exists
    def user_exists?(name)
      @users.member?(name)
    end

    #KR adds a new user to the environment
    # if name or id are already in use, this function raises an error
    def add_user(user)
      if(@users.has_key?(user.name))
        #raise error here
      end
      @users[user.name] = user
    end

    def new_user(name, display_name, pw, email, interests)
      user =  User.named(name, display_name, pw, email, interests)
      add_user user
      return user
    end

    #AS Create a new search request and add it.
    def new_search_request(keywords, user)
      search_request= SearchRequest.create(keywords, user)
      add_search_request search_request
      search_request
    end

    #AS Add a new SearchRequest
    def add_search_request(search_request)
      username= search_request.user.name
      if(@search_requests.has_key?(username))
        @search_requests[username].push(search_request)
      else
        @search_requests[username]= [search_request]
      end
    end

    #AS List SearchRequests of a user
    def search_requests_by_user(user)
      @search_requests[user.name]
    end

    #Remove a SearchRequest
    def remove_search_request(search_request_to_delete)
        @search_requests.each{|user, user_search_requests| user_search_requests.delete(search_request_to_delete)}
    end

  end
end
