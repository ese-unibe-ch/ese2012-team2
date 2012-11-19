require_relative 'data_overlay'
require_relative 'activity'

module Models
  class Trackable
    def add_activity(text)
      activity = Activity.new(self, text)
      DataOverlay.instance.add_activity(activity)
    end

    def activities
      DataOverlay.instance.activities_by_owner(self)
    end
  end
end