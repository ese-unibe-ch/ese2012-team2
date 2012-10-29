module Models
  class Comment
    attr_accessor :text, :owner, :timestamp

    def self.create text, owner, timestamp
      comment = Comment.new
      comment.text = text
      comment.owner = owner
      comment.timestamp = timestamp
    end

    def to_s
      "Owner: #{self.owner}, Time: #{self.timestamp}: #{text.split("\n")[0]}" #KR only display first line
    end
  end
end