require_relative 'trade_exception'

module Models
  class Trader
    attr_accessor :credits, :credits_in_auction, :name, :image, :interests, :display_name, :auction_bid

    def buy(item)
      unless item.owner == self
      if item.state == :active
        if item.price<=self.credits
          self.credits -= item.price
          puts "i am #{self}"
          item.take_ownership(self)
          item.state = :pending
          item.end_time = nil
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

    # checks whether the bid passes the conditions and if the same user gives the next bid
    def give_bid(auction, bid)
      if Time.now > auction.due_date
        raise TradeException, "Out of time"
      elsif auction.bid.last != nil
        if auction.bid.last.owner != self
          auction.set_bid(self, bid)
        else
          auction.update_bid(self,bid)
        end
      else
        auction.set_bid(self,bid)
      end
    end

    def items
      self.overlay.items_by_trader(self)
    end

    def active_items
      self.overlay.active_items_by_trader(self)
    end

    def pending_items
      self.overlay.pending_items_by_user(self)
    end

    def bid_on_auction
      auction_bid.push()
    end

    def overlay
      unless @data
         @data = Models::DataOverlay.instance
      end
      @data
    end
  end
end