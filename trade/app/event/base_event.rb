module Event
  class BaseEvent
    @@handlers = Set.new

    #KR registers a new Handler for this type of Event
    # ignores duplicates
    # handler should implement << arg
    def self.add_handler handler
      @@handlers.push handler
    end

    def self.fire args
      @@handlers.each {|handler|
        handler << args
      }
    end
  end
end