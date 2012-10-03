module Models
  class User
    @@users = Array.new #SH A list of all users
    attr_accessor :name, :credits, :items

    #SH Gets a user by its name
    def self.by_name(name)
      @@users.detect {|user| user.name == name }
    end

    #SH Returns all user
    def self.all
      @@users
    end

    #SH Creates a new user with his name
    def self.named(name)
     user = self.new(name)
     @@users.push(user)
     user
    end

    #SH Setup standard values
    def initialize (name)
      self.credits=100
      self.items = Array.new
      self.name = name
    end

    #SH Returns the name of the user
    def to_s
      self.name
    end

    #SH Adds a new item
    def add_new_item (name, price)
      item = Item.named(name, price, self)
      self.items.push(item)
      item
    end

    #SH Adds a existing item
    def add_item (item)
      self.items.push(item)
      item
    end

    #SH Deletes the item
    def del_item(item)
      if self.items.include? item
        self.items.delete(item)
        Models::Item.delete_item(item)
      end
    end

    #SH Checks whether the user can buy an item and then buys it
    #SH TODO refactor this method because the owner don't need to be passed
    def buy(owner, item)
      if owner.active_items.include? item
        if item.price<=self.credits
          self.credits -= item.price
          owner.credits += item.price
          self.add_item(item)
          owner.del_item(item)
        else
          return "credit error"
        end
      else
        return "item error"
      end

    end

    #SH Returns a list of all active items of a user
    def active_items
      active_items = Array.new
      self.items.each do |item|
        if item.active
          active_items.push(item)
        end
      end
      active_items
    end
  end
end