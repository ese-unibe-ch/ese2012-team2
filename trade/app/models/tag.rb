module Models
  # A tag is a single word description. It always starts with '#'
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
      name= name.downcase
      if !overlay.get_tag(name).nil?
        return overlay.get_tag(name)
      end
      tag= Tag.new(name)
      overlay.add_tag(tag)
      tag
    end

    def add_item(item)
       unless matches.include?(item)
        matches.push(item)
       end
    end

    def remove_item(item)
      matches.delete(item)
    end

    def item_applies?(item)
      matches.include?(item)
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
      get_tags_from_array( get_tag_names_from_string(str))
    end

    def self.get_tags_from_array(arr)
      tags= Array.new()
      arr.each do |name|
        if(valid?(name))
          tags.push(Tag.get_tag(name))
        end
      end
      tags
    end

    def self.get_tags_sorted_by_popularity
      overlay.get_tags.sort{|x,y| y.amount_of_matches <=> x.amount_of_matches}
    end

    def to_s
      "#{self.name}"
    end
  end
end