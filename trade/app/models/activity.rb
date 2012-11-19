class Activity

  attr_accessor :owner, :description, :date

  def initialize(owner, description)
    self.owner = owner
    self.description = description
    self.date = DateTime.now
  end
end