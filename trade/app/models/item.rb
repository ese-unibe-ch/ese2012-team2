module Models
  class Item
    @@items = Array.new #SH A list of all items
    @@item_count = 0
    attr_accessor :name, :price, :owner, :active
    attr_reader :id

    #SH Returns all items
    def self.all
      @@items
    end

    #SH Gets an item by its name
    def self.by_name(name)
      @@items.select {|item| item.name == name }
    end

    #PS get an item by id
    def self.by_id id
     @@items.detect {|item| item.id == id}
    end

    #SH Deletes an item from the item list
    def self.delete_item(item)
      @@items.delete(item)
    end

    #SH Creates a new item with a name, a price and an owner
    def self.named(name, price, owner)
      item = self.new(price, owner)
      item.name = name
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
      #PS generate a unique id and add to list of all items
      @@items << self unless @@items.include? self
      @id = @@item_count
      @@item_count += 1
      puts "created #{self}"
    end

    def to_s
      "#{self.name}, #{self.id}, #{self.owner.name}"
    end
  end
end