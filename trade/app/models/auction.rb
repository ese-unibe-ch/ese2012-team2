require_relative 'trade_exception'

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

    def initialize(user, item, params)
      @id = item.id
      self.user = user
      self.item = item
      item.state = :auction
      self.name = params[:name]
      self.description = params[:description]
      self.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
      self.minimal = params[:minimal].to_i
      self.increment = params[:increment].to_i
      self.bid = 0

      year = params[:year].to_i
      month = params[:month].to_i
      day = params[:month].to_i
      hour = params[:month].to_i
      self.due_date = Time.local(year, month, day, hour, 0,0)

      self.overlay.add_auction(self)
    end

    # set a bid under conditions
    def set_bid(new_bid)
      if new_bid >= self.bid + self.increment && new_bid >= self.minimal + self.increment
        self.bid = new_bid
      else
        raise TradeException, "To small bid!"
      end
    end

    # takes the image path from item
    def image_path
      if self.image.nil? then
        return item.image_path
      else
        return "/images/items/" + self.image
      end
    end
  end
end