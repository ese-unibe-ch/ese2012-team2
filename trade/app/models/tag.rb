module Models
  class Tag
    attr_reader :name, :matches
    @@regex= /#\w+/

    def initialize (name)
      if !Tag.valid?(name)
        raise  TradeException, "The tag format is invalid. Check if you have used the format: #YourTag"
      end
      if !overlay.getTag(name).nil?
        return overlay.getTag(name)
      end
      matches= Array.new()
    end

    def add_item(item)
       matches.push(item)
    end

    def overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    def self.valid?(name)
      !@@regex.match(name).nil?
    end

    def self.getHashtagsInString(str)
      @@regex.match(str).to_a
    end

  end
end