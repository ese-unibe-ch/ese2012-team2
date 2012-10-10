module Models
  class Item

    attr_accessor :name, :price, :owner, :active, :description, :image

    attr_reader :id

    @@item_count = 0

    #SH Creates a new item with a name, a price and an owner
    def self.named(name, price, owner, description, image=nil)
      item = self.new(name, price, owner, description, image)
    end

    #SH Sets the name, the price, and the owner of the item
    #SH If the user is not nil, adds the item to the item list of the owner
    def initialize(name, price, owner, description, image=nil)
      self.price = price
      self.owner = owner
      self.name = name
      self.description= description
      self.image = image

      self.active = false
      @id = @@item_count
      @@item_count += 1
    end


    def to_s
      "#{self.name}, #{self.id}, #{self.owner.name}"
    end

    def image_path
      if self.image.nil? then
        return "/images/items/default.png"
      else
         return "/images/items/" + self.image
      end
    end
  end
end