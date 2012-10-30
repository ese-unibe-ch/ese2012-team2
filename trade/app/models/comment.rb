module Models
  class Comment
    attr_accessor :text, :user, :owner, :timestamp

    def self.create text, user, owner, timestamp
      comment = Comment.new
      comment.text = text
      comment.owner = owner
      comment.user = user
      comment.timestamp = timestamp
      comment
    end

    def to_s
      "Owner: #{self.owner}, Time: #{self.timestamp}: #{text.split("\n")[0]}" #KR only display first line
    end
  end
end