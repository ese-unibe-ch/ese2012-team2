module Models
  class Comment
    attr_accessor :text, :user, :timestamp

    def initialize(text, user)
      self.text = text
      self.user = user
      self.timestamp = DateTime.now
    end

    def to_s
      "Owner: #{self.user}, Time: #{self.timestamp}: #{text.split("\n")[0]}" #KR only display first line
    end
  end
end