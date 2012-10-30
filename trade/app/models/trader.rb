require_relative 'trade_exception'

module Models
  class Trader
    attr_accessor :credits, :name, :image, :interests, :display_name

    def buy(item)
      unless item.owner == self
      if item.state == :active
        if item.price<=self.credits
          self.credits -= item.price
          item.take_ownership(self)
          item.state = :pending
        else
          raise TradeException, "You don't have enough credits to buy this item!"
        end
      else
        raise TradeException, "Item is not active!"
      end
      else
        raise TradeException, "You cannot buy your own item!"
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