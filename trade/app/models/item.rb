module Models
  class Item

    attr_accessor :name, :price, :owner, :state, :description, :image, :prev_owners

    attr_reader :id, :comments

    @@item_count = 0

    #SH Creates a new item with a name, a price and an owner
    def self.named(name, price, owner, description, image=nil)
      item = self.new(name, price, owner, description, image)
    end

    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    #SH Sets the name, the price, and the owner of the item
    #SH If the user is not nil, adds the item to the item list of the owner
    def initialize(name, price, owner, description, image=nil)
      self.price = price
      self.owner = owner
      self.name = name
      self.description= description
      self.image = image
      self.prev_owners = Array.new

      @comments = Array.new

      self.state = :inactive
      @id = @@item_count
      @@item_count += 1

      self.overlay.add_item(self)
    end

    def add_comment comment
      self.comments.push comment
    end

    def take_ownership(new_owner)
      self.prev_owners << self.owner
      self.owner = new_owner
    end

    def to_s
      self.name
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