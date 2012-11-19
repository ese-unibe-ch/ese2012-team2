class Activity

  attr_accessor :owner, :description, :date

  def initialize(owner, description, date)
    #TODO add to overlay
    self.owner = owner
    self.description = description
    self.date = date
  end
end