require_relative 'trade_exception'
require_relative 'bid'
require_relative '../../../trade/app/helpers/email_sender'

module Models
  class Auction
    attr_accessor :user, :item, :current_price, :name, :minimal, :increment, :due_date, :description, :image, :bid, :rank_one, :rank_two
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
      self.current_price = self.minimal
      self.rank_one=nil
      self.rank_one=nil
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      hour = params[:hour].to_i
      self.due_date = Time.local(year, month, day, hour, 0, 0)

      self.overlay.add_auction(self)
    end

    # set a bid under conditions
    def set_bid(user, new_bid)
      if new_bid >= self.current_price + self.increment && new_bid >= self.minimal
        unless self.bid.empty?
          self.bid.last.bid_placed_by.credits += self.bid.last.max_bid
        end
        tmp_bid = bid.last


        self.bid.push Models::Bid.new_bid(user, new_bid)

        send_email(tmp_bid) unless tmp_bid==nil
        self.item.price = new_bid
      else
        raise TradeException, "To small bid!"
      end
      invariant
    end

    def user_raise_bid(user, amount)

      invariant
    end

    def invariant
      get_current_ranking

      self.rank_one = self.bid.last
      self.rank_two = self.bid[-2] unless self.bid.size <2

      if self.rank_one != nil and self.rank_two!=nil
      #send_email(self.rank_two.bid_placed_by)
      end
      get_current_price
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

    # sorts the bid array in descending order
    def get_current_ranking
      self.bid.sort { |a, b| a.max_bid <=> b.max_bid }
      self.bid =self.bid.reverse
    end

    # returns the price incremented by highest bid
    def get_current_price
      if rank_two!=nil
          self.current_price= rank_two.max_bid + increment
      else
        self.current_price = self.minimal
      end

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
      if tmp_bid.bid_placed_by != self.bid.last.bid_placed_by
        EmailSender.send_auction(tmp_bid.bid_placed_by, self.item)
        puts "Email sendt" #for testing only
      end
    end
  end
end