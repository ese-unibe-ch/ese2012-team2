require_relative 'data_overlay'
require_relative 'activity'
require_relative 'trade_exception'

module Models
  # an interface for an object that can log certain activities
  class Trackable
    def add_activity(text)
      activity = Activity.new(self, text)
      DataOverlay.instance.add_activity(activity)
    end

    def activities
      DataOverlay.instance.activities_by_owner(self)
    end

    #must be overridden in subclasses!
    def track_id
      raise TradeException, "track_id not implemented"
    end
  end
end