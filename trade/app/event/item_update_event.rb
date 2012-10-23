module Event
  class ItemUpdateEvent < BaseEvent
    def self.item_created item
      self.fire({:type => :item_created, :item => item})
    end

    def self.item_changed item
      self.fire({:type => :item_changed, :item => item})
    end
  end
end