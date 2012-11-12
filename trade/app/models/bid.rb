module Models
  class Bid
    attr_accessor :owner, :value

    def self.initialize
      self.owner = nil
      self.value = 0
    end

    # saves the new bid for the auction
    def self.new_bid(user, max_bid)
      bid = Bid.new()
      bid.owner = user
      bid.value = max_bid
      return bid
    end

    # raises the bid by the increment
    def rise_bid(increment)
      max_bid = max_bid + increment unless increment <= 0
    end
  end
end
