require_relative 'trade_exception'
require_relative 'trackable'
require_relative 'activity'

module Models
  class Item < Trackable

    attr_accessor :name, :price, :owner, :state, :description, :image, :prev_owners, :end_time

    def name=(name)
      add_activity "name was changed from #{self.name} to #{name}" unless @name == name
      @name=name
    end

    def price=(price)
      add_activity "price was changed from #{self.price} to #{price}" unless @price == price
      @price = price
    end

    def state=(state)
      add_activity "state changed from #{self.state} to #{state}"  unless @state == state
      @state = state
    end

    def description=(description)
      add_activity "description was edited" unless @description == description
      @description = description
    end

    def image=(image)
      add_activity "image was changed" unless @image == image
      @image = image
    end

    attr_reader :id, :comments

    @@item_count = 0

    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    #SH Sets the name, the price, and the owner of the item
    #SH If the user is not nil, adds the item to the item list of the owner
    #AS The parameter request means, the item is added as an item request. Defaultly it's false.
    def initialize(name, price, owner, description, state=:inactive, image=nil, request=false, end_time=nil)
      self.price = Models::Item.validate_price price

      if owner.nil?
        raise TradeException, "Owner may not be empty!"
      end
      @owner = owner

      if name.empty?
        raise TradeException, "Name must not be empty!"
      end
      @name = name
      @description= description
      @image = image
      self.prev_owners = Array.new

      @comments = Array.new

      @state = state

      puts "end time: #{end_time}"
      @end_time = end_time

      @id = @@item_count
      @@item_count += 1
      if(request)
        self.overlay.add_item_request(self)
      else
        self.overlay.add_item(self)
      end

      self.overlay.add_item(self)
      owner.add_activity "has created item #{name}"
    end

    def self.validate_price price
      if price.is_a?(String)
        unless price.match('^[0-9]+$')
          raise TradeException, "Price must be number"
        end
        p = price.to_i
      else
        p = price
      end
      unless p >= 0
        raise TradeException, "Price must be positive"
      end
      p
    end

    def add_comment comment
      add_activity "commented by #{comment.user}"
      comment.user.add_activity "commented item #{self.name} from #{self.owner}"
      self.comments.push comment
    end

    def take_ownership(new_owner)
      self.prev_owners << self.owner
      if new_owner.is_a?(Models::User)
        new_owner.remove_wish self
      end
      self.owner.add_activity "Sold item #{self.name} to #{new_owner.name} for #{self.price}."
      new_owner.add_activity "Bought item #{self.name} from #{self.owner.name} for #{self.price}."
      @owner = new_owner
    end

    def over?
      unless self.end_time == nil
        self.end_time < DateTime.now
      end
    end

    def end_offer
      @end_time = nil
      @state = :inactive
      self.add_activity "offer expired"
    end

    def to_s
      self.name
    end

    def formatted_end_time
      unless self.end_time.nil?
        self.end_time.strftime("%d-%m-%Y")
      end
    end

    def track_id
      "item$#{self.id}"
    end

    def image_path
      if self.image.nil? then
        return "/images/items/default.png"
      else
         return "/images/items/" + self.image
      end
    end
  end
end