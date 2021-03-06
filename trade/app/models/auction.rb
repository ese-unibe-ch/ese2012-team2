require_relative 'trade_exception'
require_relative 'bid'
require_relative 'user'
require_relative 'trader'
require_relative '../helpers/email_sender'

# This class is responsible for all changes for the object auction
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
      self.current_price = 0
      self.rank_one=nil
      self.rank_two=nil
      date = params[:date]
      year = date[6..9].to_i
      month = date[3..4].to_i
      day = date[0..1].to_i
      time = params[:time]
      hour = time.split(":").first.to_i
      min = time.split(":").last.to_i

      self.due_date = Time.local(year, month, day, hour, min, 0)

      self.overlay.add_auction(self)
    end

    #Updates a given bid of the same user
    def update_bid(user, new_bid)
      available_credits_for_update = (self.bid.last.value + user.credits)
      if new_bid > available_credits_for_update
        raise TradeException, "Not enough money!"
      elsif new_bid <= self.bid.last.value
        raise TradeException, "You've already given a higher bid!"
      else
        additional_credit_cost = (new_bid - self.bid.last.value)
        user.credits -= additional_credit_cost
        user.credits_in_auction += additional_credit_cost
        self.bid.last.value = new_bid
        self.invariant
      end
    end

    #Checks if the given bid is the highest
    def check_bids(user, new_bid)
      previous_winner = self.bid.last.owner
      if user.credits < new_bid
        raise TradeException, "Not enough money!" unless user.credits >= new_bid
      elsif self.bid.last.value == new_bid
        raise TradeException, "That's already the highest bid!"
      elsif self.bid.last.value < new_bid
        previous_winner.credits += self.bid.last.value
        previous_winner.credits_in_auction -= self.bid.last.value
        user.credits -= new_bid
        user.credits_in_auction += new_bid
      end
    end

    # set a bid under conditions
    def set_bid(user, new_bid)
      if new_bid >= self.current_price + self.increment && new_bid >= self.minimal
          unless self.bid.empty?
            check_bids(user,new_bid)
          else
            raise TradeException, "Not enough money!" unless user.credits >= new_bid
            user.credits -= new_bid
            user.credits_in_auction += new_bid
          end
        tmp_bid = bid.last
        self.bid.push Models::Bid.new_bid(user,new_bid)
        user.add_activity"has bid on item #{item.name} from #{item.owner}"
        unless tmp_bid == nil
          send_email(tmp_bid) if tmp_bid.value < new_bid
        end
      else
        raise TradeException, "Too small bid!"
      end
      self.invariant
    end

    # helper method
    def invariant
      self.get_current_ranking
      self.rank_one = self.bid.last
      self.rank_two = self.bid[-2] unless self.bid.size <2
      self.get_current_price
    end

    # checks for price input
    def self.validate_minimal price
      if price.is_a?(String)
        unless price.match('^[0-9]+$')
          raise TradeException, "Minimal price must be a number!"
        end
        p = price.to_i
      else
        p = price
      end
      unless p >= 0
        raise TradeException, "Minimal price must be positive!"
      end
      p
    end

    # checks for increment input
    def self.validate_increment amount
      if amount.is_a?(String)
        unless amount.match('^[0-9]+$')
          raise TradeException, "Increment must be a number!"
        end
        p = amount.to_i
      else
        p = amount
      end
      unless p > 0
        raise TradeException, "Increment must be positive!"
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

    # returns the current_winner of the auction
    def get_current_winner
      if self.rank_one == nil
        return nil
      else
        return rank_one.owner
      end
    end

    # sorts the bid array in ascending order
    def get_current_ranking
      self.bid = self.bid.sort { |a, b| a.value <=> b.value }
    end

    # returns the price incremented by highest bid
    def get_current_price
      if rank_two!=nil
          self.current_price= (rank_two.value + increment > rank_one.value ? rank_one.value : rank_two.value + increment)
      else
        self.current_price = self.minimal
      end

    end

    # returns the current highest bid
    def get_current_bid
      self.get_current_ranking
      if self.bid.empty?
        return 0
      else
        return bid.last.value
      end
    end

    # if time is over and a bidder exists, then item gets sold
    def sell_to_current_winner
      if self.rank_one != nil
        winner = self.get_current_winner
        item.price = self.get_current_price
        item.take_ownership(winner)
        item.state = :pending
        winner.credits_in_auction -= self.get_current_bid
        winner.credits += (self.get_current_bid - self.get_current_price)
        EmailSender.win_auction(winner, item)
      else
        item.state = :inactive
      end
    end

    #returns true if auction time is over
    def time_over?
      return self.due_date <= Time.now
    end

    # send a mail to if another user gave a higher bid
    def send_email(tmp_bid)
      EmailSender.send_auction(tmp_bid.owner, self.item)
    end
  end
end