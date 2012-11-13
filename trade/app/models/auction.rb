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
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      hour = params[:hour].to_i
      self.due_date = Time.local(year, month, day, hour, 0, 0)

      self.overlay.add_auction(self)
    end

    #Checks if an user updates his last bid or if he bids against the current_winner
    def update_own_bid?(user, new_bid)
      updated_own_bid = false
      previous_winner = self.bid.last.owner
      if self.bid.last.value == new_bid
        raise TradeException, "That's already the highest bid!"
      elsif self.bid.last.value < new_bid
        previous_winner.credits += self.bid.last.value
        previous_winner.credits_in_auction -= self.bid.last.value
        raise TradeException, "Not enough money!" unless user.credits >= new_bid
        user.credits -= new_bid
        user.credits_in_auction += new_bid
      end
      if previous_winner == user and new_bid <= bid.last.value
        raise TradeException, "You've already given a higher bid!"
      elsif previous_winner == user
        bid.last.value = new_bid
        updated_own_bid = true
      end
      return updated_own_bid
    end

    # set a bid under conditions
    def set_bid(user, new_bid)
      updated_own_bid = false
      if new_bid >= self.current_price + self.increment && new_bid >= self.minimal
          unless self.bid.empty?
            updated_own_bid = self.update_own_bid?(user, new_bid)
          else
            raise TradeException, "Not enough money!" unless user.credits >= new_bid
            user.credits -= new_bid
            user.credits_in_auction += new_bid
          end
        tmp_bid = bid.last
        unless updated_own_bid
          self.bid.push Models::Bid.new_bid(user,new_bid)
          unless tmp_bid == nil
            send_email(tmp_bid) if tmp_bid.value < new_bid
          end
        end
      else
        raise TradeException, "To small bid!"
      end
      invariant
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
      if tmp_bid.owner != self.bid.last.owner
        EmailSender.send_auction(tmp_bid.owner, self.item)
        puts "Email sent" #for testing only
      end
    end
  end
end