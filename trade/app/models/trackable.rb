class Trackable
  def add_activity(text)
    activity = Activity.new(self, text, DateTime.now)
  end

  def activities
    #TODO return all activities for this dingsbums
  end
end