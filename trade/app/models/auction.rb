require_relative 'trade_exception'

module Models
  class Auction
    attr_accessor :user, :item, :name, :price, :minimal, :increment, :time, :description, :image
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
      self.price = params[:price]
      self.description = params[:description]
      self.image = ImageHelper.save params[:image], settings.public_folder + "/images/items"
      self.minimal = params[:minimal]
      self.increment = params[:increment]
      self.time = params[:time]

      #@id = @@auction_count
      #@@auction_count += 1
      @id = item.id

      self.overlay.add_auction(self)
    end

    #increments the price
    def inc
      self.price += increment
    end
  end
end