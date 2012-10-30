module Models
  class Trader
    attr_accessor :credits

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
      @data = Models::DataOverlay.instance
      @data.items_by_trader(self)
    end
  end
end