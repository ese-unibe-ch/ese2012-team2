module Models
  class Trader
    attr_accessor :credits, :name, :image, :interests, :display_name

    def buy(item)
      if item.state == :active
        if item.price<=self.credits
          self.credits -= item.price
          item.take_ownership(self)
          item.state = :pending
        else
          return "credit error"
        end
      else
        return "item error"
      end
    end

    def items
      self.overlay.items_by_trader(self)
    end

    def overlay
      unless @data
         @data = Models::DataOverlay.instance
      end
      @data
    end
  end
end