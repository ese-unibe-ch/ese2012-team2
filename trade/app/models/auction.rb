require_relative 'trade_exception'

module Models
  class Auction
    attr_accessor :user, :item, :name, :price, :minimal, :increment, :time, :description, :image, :bid
    attr_reader :id
    #@@auction_count = 0

    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    def initialize(user, item, params)
      #self.price = Models::Item.validate_price price
      self.user = user
      self.item = item
      self.name = params[:name]
      self.price = params[:price].to_i
      self.description = params[:description]
      self.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
      self.minimal = params[:minimal].to_i
      self.increment = params[:increment].to_i
      self.time = params[:time]
      self.bid = []

      #@id = @@auction_count
      #@@auction_count += 1
      @id = item.id

      self.overlay.add_auction(self)
    end

    #increments the price
    def inc
      self.price += increment
    end

    def set_bid(new_bid)
      if new_bid >= self.bid + self.increment && new_bid >= self.minimal + self.increment
        self.bid.push new_bid
      end
    end

    def image_path
      if self.image.nil? then
        return item.image_path
      else
        return "/images/items/" + self.image
      end
    end

    def get_current_ranking
      bid.sort {|a,b|a.max_bid <=> b.max_bid}
      bid.reverse
    end

    def get_current_price
      second_bid =bid[1].max_bid
      current_price =0
      while current_price<second_bid do
        current_price+= increment
      end

    end

    # @param [Trader] trader
    def bidder_rise_bid(trader,to_rise)
       bid.find(trader).rise_bid(to_rise)
    end


  end
end