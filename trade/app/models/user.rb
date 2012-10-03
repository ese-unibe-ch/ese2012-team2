module Models
  class User
    @@users = Array.new
    attr_accessor :name, :credits, :items

    def self.by_name(name)
      @@users.detect {|user| user.name == name }
    end

    def self.all
      @@users
    end

    def self.named(name)
     user = self.new(name)
     @@users.push(user)
     user
    end

    def initialize (name)
      self.credits=100
      self.items = Array.new
      self.name = name
    end

    def to_s
      self.name
    end

    def add_item (name, price)
      item = Item.named(name, price, self)
      self.items.push(item)
      item
    end

    def del_item(item)
      if (self.items.include? item)
        self.items.delete(item)
        Models::Item.delete_item(item)
      end
    end

    def buy(owner, item)
      if owner.item_list.include? item
        if item.price<=self.credits
          self.credits -= item.price
          owner.credits += item.price
          self.add_item(item.name, item.price)
          owner.del_item(item)
        else
          return "credit error"
        end
      else
        return "item error"
      end

    end

    def item_list
      active_items = Array.new
      self.items.each do |item|
        if item.active == true
          active_items.push(item)
        end
      end
      active_items
    end
  end
end