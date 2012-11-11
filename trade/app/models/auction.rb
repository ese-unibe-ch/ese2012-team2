require_relative 'trade_exception'
require_relative 'bid'
require_relative 'user'
require_relative 'trader'
require_relative '../../../trade/app/helpers/email_sender'

module Models
  class Auction
    attr_accessor :user, :item, :name, :minimal, :increment, :due_date, :description, :image, :bid
    attr_reader :id

    # get the data from data base
    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    # creates a new auction with the id of the item
    def initialize(user, item, params)
      @id = item.id
      self.user = user
      self.item = item
      item.state = :auction
      self.name = item.name
      self.description = params[:description]
      self.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
      self.minimal = params[:minimal].to_i
      self.increment = params[:increment].to_i
      self.bid = []

      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      hour = params[:hour].to_i
      self.due_date = Time.local(year, month, day, hour, 0, 0)

      self.overlay.add_auction(self)
    end

    # set a bid under conditions
    def set_bid(user, new_bid)
      if new_bid >= self.get_current_bid + self.increment && new_bid >= self.minimal + self.increment
        unless self.bid.empty?
          self.bid.last.bid_placed_by.credits += self.bid.last.max_bid
        end
        tmp_bid = bid.last
        self.bid.push Models::Bid.new_bid(user,new_bid)
        send_email(tmp_bid) unless tmp_bid==nil
        self.item.price = new_bid
      else
        raise TradeException, "To small bid!"
      end
    end

    # checks for price input
    def self.validate_minimal price
      if price.is_a?(String)
        unless price.match('^[0-9]+$')
          raise TradeException, "Minimal price must be number"
        end
        p = price.to_i
      else
        p = price
      end
      unless p >= 0
        raise TradeException, "Minimal must be positive"
      end
      p
    end

    # checks for increment input
    def self.validate_increment amount
      if amount.is_a?(String)
        unless amount.match('^[0-9]+$')
          raise TradeException, "Increment must be number"
        end
        p = amount.to_i
      else
        p = amount
      end
      unless p > 0
        raise TradeException, "Increment must be positive"
      end
      p
    end

    # takes the image path from item
    def image_path
      if self.image.nil? then
        return item.image_path
      else
        return "/images/items/" + self.image
      end
    end

    def get_current_winner
      self.get_current_ranking
      return bid[0].bid_placed_by
    end

    # sorts the bid array in descending order
    def get_current_ranking
      bid.sort { |a, b| a.max_bid <=> b.max_bid }
      bid.reverse
    end

    # returns the price incremented by highest bid
    def get_current_price
      second_bid = bid[1].max_bid
      while current_price < second_bid do
        current_price+= increment
      end
      return current_price
    end

    # returns the current highest bid
    def get_current_bid
      if self.bid.empty?
        return 0
      else
        return bid.last.max_bid
      end
    end

    def send_email(tmp_bid)
      if tmp_bid.bid_placed_by != bid.last.bid_placed_by
         EmailSender.send_auction(tmp_bid.bid_placed_by, self.item)
         puts "Email sent"         #for testing only
      end
    end
  end
end