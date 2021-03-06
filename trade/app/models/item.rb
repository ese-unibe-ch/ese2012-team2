require_relative 'trade_exception'
require_relative 'trackable'
require_relative 'activity'

module Models
  # represents an item. An item has a name a non-negative price and an owner. The owner
  # should be a user or organization. An item has a state weither it is for sale, not for sale
  # or being transfered between two users. An item maintains a list of all it previous owners.
  class Item < Trackable

    attr_accessor :name, :price, :owner, :state, :descriptions, :image, :prev_owners, :end_time, :quantity

    def name=(name)
      add_activity "name was changed from #{self.name} to #{name}" unless @name == name
      @name=name
    end

    def price=(price)
      add_activity "price was changed from #{self.price} to #{price}" unless @price == price
      @price = price
    end

    def state=(state)
      unless @state == state
        add_activity "state changed from #{self.state} to #{state}"
        owner.add_activity "has changed state of #{self.name} from #{self.state} to #{state}"
      end
      @state = state
    end

    def quantity=(quantity)
      unless @quantity == quantity
        add_activity "quantity was changed from #{self.quantity} to #{quantity}"
      end
      @quantity = quantity
    end

    def description=(description)
      unless @descriptions.last == description
        add_activity "description was edited"
        @descriptions.push description
      end
    end

    def description
      @descriptions.last
    end

    def image=(image)
      add_activity "image was changed" unless @image == image
      @image = image
    end

    def end_time=(end_time)
      if end_time.nil?
        self.add_activity "end time was deleted" unless  self.end_time.nil?
      else
        if self.end_time.nil?
          self.add_activity "end time was set to #{end_time.strftime("%d.%m.%Y %H:%M")}"
        else
          self.add_activity "end time was changed from #{self.formatted_end_time} to #{end_time.strftime("%d.%m.%Y %H:%M")}" unless @end_time == end_time
        end
      end
      @end_time = end_time
    end

    attr_reader :id, :comments

    @@item_count = 0

    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    def copy_for(owner, quantity)
      item = Models::Item.new(@name, @price, owner, @descriptions.last, @state, @image, false, @end_time, quantity)
      self.activities.each { |act|
        copied_act = act.copy_for(owner)
        self.overlay.add_activity(copied_act)
      }
      item
    end

    #SH Sets the name, the price, and the owner of the item
    #SH If the user is not nil, adds the item to the item list of the owner
    #AS The parameter request means, the item is added as an item request. Defaultly it's false.
    def initialize(name, price, owner, description, state=:inactive, image=nil, request=false, end_time=nil, quantity=1)
      @price = Models::Item.validate_price price

      if owner.nil?
        raise TradeException, "Owner may not be empty!"
      end
      @owner = owner

      if name.empty?
        raise TradeException, "Name must not be empty!"
      end
      @name = name
      @descriptions= Array.new
      @descriptions.push description
      @image = image
      self.prev_owners = Array.new

      @comments = Array.new

      @state = state
      @quantity = Models::Item.validate_quantity(quantity)

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
      self.add_activity "item was created"
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

    def self.validate_quantity quantity
      if quantity.is_a?(String)
        unless quantity.match('^[0-9]+$')
          raise TradeException, "Price must be number"
        end
        p = quantity.to_i
      else
        p = quantity
      end
      unless p >= 1
        raise TradeException, "Quantity must be 1 or more"
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
      self.add_activity "sold to #{new_owner.display_name}"
      @owner = new_owner
    end

    def over?
      unless self.end_time.nil?
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
        self.end_time.strftime("%d.%m.%Y %H:%M")
      end
    end

    def formatted_end_time_date
      unless self.end_time.nil?
        self.end_time.strftime("%d-%m-%Y")
      end
    end

    def formatted_end_time_time
      unless self.end_time.nil?
        self.end_time.strftime("%H:%M")
      end
    end

    def track_id
      "item$#{self.id}"
    end

    def activities
      self.overlay.activities_by_owner(self)
    end

    def tags
      self.overlay.tags_by_item(self).collect { |tag| tag.name }
    end

    def remove_all_tags
      self.overlay.remove_all_tags_from_item(self)
    end

    def image_path
      if self.image.nil? then
        return "/images/items/default.png"
      else
         return "/images/items/" + self.image
      end
    end

    #AS Adds the item to a tag. (Double Dispatch)
    def add_tag(tag)
      tag.add_item(self)
    end

    def similar_items
       self.overlay.similar_items(self)
    end
  end
end