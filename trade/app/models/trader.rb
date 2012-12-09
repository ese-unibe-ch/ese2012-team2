require_relative 'trade_exception'
require_relative 'trackable'

module Models
  class Trader < Trackable
    attr_accessor :credits, :credits_in_auction, :name, :image, :interests, :display_name, :auction_bid

    def buy(item, quantity)
      if item.owner == self
        raise TradeException, "You cannot buy your own item!"
      else
        if item.state == :active
          if quantity > item.quantity
            quant = item.quantity
          else
            quant = quantity
          end
          money_needed = item.price * quant
          if money_needed <=self.credits
            self.credits -= money_needed
            if quant < item.quantity
              # only sell a part
              part = item.copy_for(self, quant)
              part.take_ownership(self)
              part.state = :pending
              item.quantity = item.quantity - quant
            else
              # sell the whole item
              item.take_ownership(self)
              item.state = :pending
            end
          else
            self.add_activity_failed_purchase item
            raise TradeException, "You don't have enough credits to buy this item!"
          end
        else
          raise TradeException, "Item is not active!"
        end
      end
    end

    #AS Buys a priorly (in the item request list) requested item.
    def buy_requested_item(request, item)
      self.overlay.delete_item_request(request.id)
      item.price = request.price #The prize given in the request is relevant.
      buy(item, true)
    end

    #AS Sells a requested item - contract: Trader has a matching item.
    def sell_requested_item(request, buyer)
      item = get_matching_item(request)
      buyer.buy_requested_item(request, item)
    end
    #AS Checks if a trader is able to fulfill a particular item request
    def can_fulfill_request?(request)
      matching_items= self.overlay.active_items_by_name_and_user(request.name, self)
      matching_items.size > 0
    end

    #AS Selects a item witch matches to the item request of another user. At the moment the matching criterion is the name.
    #But because the name isn't a unique property, just the first found item is selected. (Aaron didn't specify a more specific matching criterion)
    def get_matching_item(request)
      matching_items= self.overlay.active_items_by_name_and_user(request.name, self)
      matching_items[0]
    end

    def add_activity_failed_purchase item
      self.add_activity "failed to buy item #{item.name}"
      item.owner.add_activity "selling item #{item.name} to #{self.display_name} failed"
      item.add_activity "buying failed for #{self.display_name}"
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