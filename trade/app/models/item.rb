require_relative 'trade_exception'

module Models
  class Item

    attr_accessor :name, :price, :owner, :state, :description, :image, :prev_owners

    attr_reader :id, :comments

    @@item_count = 0

    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    #SH Sets the name, the price, and the owner of the item
    #SH If the user is not nil, adds the item to the item list of the owner
    def initialize(name, price, owner, description, state=:inactive, image=nil)
      self.price = Models::Item.validate_price price

      if owner.nil?
        raise TradeException, "Owner may not be empty!"
      end
      self.owner = owner

      if name.empty?
        raise TradeException, "Name must not be empty!"
      end
      self.name = name
      self.description= description
      self.image = image
      self.prev_owners = Array.new

      @comments = Array.new

      self.state = state
      @id = @@item_count
      @@item_count += 1

      self.overlay.add_item(self)
    end

    def self.validate_price price
      if price.is_a?(String)
        unless price.match('^[0-9]+$')
          raise TradeException, "Price must be number"
        end
        p = price.to_i
      else
        p = price
      end
      unless p >= 0
        raise TradeException, "Price must be positive"
      end
      p
    end

    def add_comment comment
      self.comments.push comment
    end

    def take_ownership(new_owner)
      puts "owner is #{self.owner}"
      self.prev_owners << self.owner
      if new_owner.is_a?(Models::User)
        new_owner.remove_wish self
      end
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