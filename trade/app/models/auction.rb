require_relative 'trade_exception'
require_relative 'bid'
require_relative 'user'
require_relative 'trader'
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
      self.current_price = 0
      self.rank_one = nil
      self.rank_one = nil
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:day].to_i
      hour = params[:hour].to_i
      self.due_date = Time.local(year, month, day, hour, 0, 0)

      self.overlay.add_auction(self)
    end

    # set a bid under conditions
    def set_bid(user, new_bid)
      updated_own_bid = false
      if new_bid >= self.current_price + self.increment && new_bid >= self.minimal
          unless self.bid.empty?
            previous_winner = self.bid.last.bid_placed_by
            if self.bid.last.max_bid < new_bid
              previous_winner.credits += self.bid.last.max_bid
              previous_winner.credits_in_auction -= self.bid.last.max_bid
              user.credits -= new_bid
              user.credits_in_auction += new_bid
            end
            if previous_winner == user and new_bid <= bid.last.max_bid
              raise TradeException, "You've already given a higher bid!"
            elsif previous_winner == user
              bid.last.max_bid = new_bid
              updated_own_bid = true
            end
          else
            user.credits -= new_bid
            user.credits_in_auction += new_bid
          end
        tmp_bid = bid.last
        unless updated_own_bid
          self.bid.push Models::Bid.new_bid(user,new_bid)
          send_email(tmp_bid) unless tmp_bid==nil
        end
      else
        raise TradeException, "To small bid!"
      end
      invariant
    end

    def invariant
      self.get_current_ranking

      self.rank_one = self.bid.last
      self.rank_two = self.bid[-2] unless self.bid.size <2

      if self.rank_one != nil and self.rank_two!=nil
      #send_email(self.rank_two.bid_placed_by)
      end
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

    #returns the current_winner of the auction
    def get_current_winner
      return rank_one.bid_placed_by
    end

    # sorts the bid array in ascending order
    # sorts the bid array in descending order
    def get_current_ranking
      self.bid = self.bid.sort { |a, b| a.max_bid <=> b.max_bid }
    end

    # returns the price incremented by highest bid
    def get_current_price
      if rank_two != nil
        self.current_price = rank_two.max_bid + increment
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
        return bid.last.max_bid
      end
    end

    def sell_to_current_winner
      if self.rank_one != nil
        winner = self.get_current_winner
        item.price = self.get_current_price
        item.take_ownership(winner)
        item.state = :pending
        winner.credits_in_auction -= self.get_current_bid
        winner.credits += (self.get_current_bid - self.get_current_price)
      end
    end

    def time_over?
      return self.due_date <= Time.now
    end

    def send_email(tmp_bid)
      if tmp_bid.bid_placed_by != self.bid.last.bid_placed_by
        EmailSender.send_auction(tmp_bid.bid_placed_by, self.item)
        puts "Email sent" #for testing only
      end
    end
  end
end