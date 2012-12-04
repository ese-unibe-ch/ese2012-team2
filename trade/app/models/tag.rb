module Models
  class Tag
    attr_reader :name, :matches
    @@regex= /#\w+/

    def initialize (name)
      if !Tag.valid?(name)
        raise  TradeException, "The tag format is invalid. Check if you have used the format: #YourTag"
      end
      @name=name
      @matches= Array.new()

    end

    #AS If there's already a tag with this name, it's returned. Else a new one is created transparently.
    def self.get_tag(name)

      if !overlay.get_tag(name).nil?
        return overlay.get_tag(name)
      end
      tag= Tag.new(name)
      overlay.add_tag(tag)
      tag
    end

    def add_item(item)
       if matches.count(item)==0
        matches.push(item)
       end
    end

    def amount_of_matches
      matches.length
    end
    def self.overlay
      unless @data
        @data = Models::DataOverlay.instance
      end
      @data
    end

    def self.valid?(name)
      name.slice(@@regex)==name
    end

    def self.get_tag_names_from_string(str)
      str.split(" ").delete_if{|item| !Tag.valid?(item)}
    end

    def self.get_tags_from_string(str)
      hashtags= Array.new()
      get_tag_names_from_string(str).each do |name|
        hashtags.push(Tag.new(name))
      end
      hashtags
    end

    def self.get_tags_sorted_by_popularity
      overlay.get_tags.sort{|x,y| x.amount_of_matches <=> y.amount_of_matches}
    end


  end
end