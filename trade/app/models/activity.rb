module Models

  #represents a loggable event triggered or happend to another class. This class is specified by the owner attribute.
  # In addition to the owner this class has a description providing further information and a date which is the
  #initiation time of the activity object
  class Activity

    attr_accessor :owner, :description, :date

    def initialize(owner, description)
      self.owner = owner
      self.description = description
      self.date = DateTime.now
    end

    def formatted_date
      self.date.strftime("%d.%m.%Y - %H:%M")
    end

    def copy_for(owner)
      act = Activity.new(owner, self.description)
      act.date = self.date
      act
    end
  end
end