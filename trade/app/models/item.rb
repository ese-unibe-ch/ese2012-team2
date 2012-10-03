module Models
  class Item
    @@items = Array.new
    attr_accessor :name, :price, :owner, :active

    def self.all
      @@items
    end

    def self.by_name(name)
      @@items.detect {|item| item.name == name }
    end

    def self.delete_item(item)
      @@items.delete(item)
    end

    def self.named(name, price, owner)
      item = self.new(price, owner)
      item.name = name
      @@items.push(item)
      item
    end

    def initialize(price, owner)
      self.price = price
      self.owner = owner
      self.active = false
    end
  end
end