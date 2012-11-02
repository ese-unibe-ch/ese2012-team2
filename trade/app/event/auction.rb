module Models
  class Auction
    attr_accessor :owner, :name, :price, :minimal_price, :increment, :end_time, :description, :image

    def initialize(name, price, owner, description, image=nil)
      self.price = Models::Item.validate_price price
      self.owner = owner

      if name.empty?
        raise TradeException, "Name must not be empty!"
      end
      self.name = name
      self.description = description
      self.image = image
      self.prev_owners = Array.new

      self.state = state
      @id = @@item_count
      @@item_count += 1

      self.overlay.add_item(self)
    end
  end
end