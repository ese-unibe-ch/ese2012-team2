module Models
  #represents a comment on something by someone. This class contains the data of a single Comment providing
  #who commented, when, on what. And, of course, the actual content of the comment
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