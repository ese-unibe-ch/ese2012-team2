module Models
  class Item
    @@items = Array.new #SH A list of all items
    attr_accessor :name, :price, :owner, :active

    #SH Returns all items
    def self.all
      @@items
    end

    #SH Gets an item by its name
    def self.by_name(name)
      @@items.detect {|item| item.name == name }
    end

    #SH Deletes an item from the item list
    def self.delete_item(item)
      @@items.delete(item)
    end

    #SH Creates a new item with a name, a price and an owner
    def self.named(name, price, owner)
      item = self.new(price, owner)
      item.name = name
      @@items.push(item)
      item
    end

    #SH Sets the name, the price, and the owner of the item
    #SH If the user is not nil, adds the item to the item list of the owner
    def initialize(price, owner)
      self.price = price
      self.owner = owner
      if self.owner
        self.owner.add_item(self)
      end
      self.active = false
    end
  end
end