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
      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:month].to_i
      hour = params[:month].to_i
      self.time = Time.local(year, month, day, hour, 0,0)
      self.bid = 0

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
        self.bid = new_bid
      else
        raise TradeException, "To small bid!"
      end
    end

    def image_path
      if self.image.nil? then
        return item.image_path
      else
        return "/images/items/" + self.image
      end
    end
  end
end