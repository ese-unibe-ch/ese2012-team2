require_relative '../models/trade_exception'

module Models
  #KR This class is responsible for Item & User management. It contains maps holding all items and users
  # and offers useful operations on these maps.
  class DataOverlay

    def initialize
      @users = Hash.new
      @items = Hash.new
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

    #KR adds a new item to the environment.
    # if the id is already in use, raises an error
    def add_item(item)
      if @items[item.id]
        raise TradeException, "Item already exists"
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
      @items.values.select {  |value| value.owner==user }
    end

    def active_items_by_user(user)
      @items.values.select { |value| value.owner==user and value.state == :active }
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

    #AS checks if a user exists
    def user_exists?(name)
      @users.member?(name)
    end

    #PS all objects are true except nil & false ;)
    def user_display_name_exists?(display_name)
      @users.values.detect { |user| user.display_name == display_name }
    end

    #KR adds a new user to the environment
    # if name or id are already in use, this function raises an error
    def add_user(user)
      if @users[user.name]
        raise TradeException, "User already exists!"
      end
      @users[user.name] = user
    end

    def new_user(name, display_name, pw, email, interests = nil)
      user =  User.named(name, display_name, pw, email, interests)
      add_user user
      return user
    end
  end
end
