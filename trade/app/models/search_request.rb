module Models
  #AS Models a search request. Create one by giving the keywords and check with applies? if an item matches.
  class SearchRequest
    attr_accessor :keywords, :user
    def self.create(keywords, user)
      self.new(keywords, user)
    end

    def initialize(keywords, user)
      self.keywords=keywords
      self.user= user
    end

    #AS Check if a given Item matches to the SearchRequest instance
    def applies?(item)
      applies_for_all = true
      keywords.each do |keyword|
        if !applies_for_all
          break
        end
        applies_for_all= applies_for_all && ((item.name.include? keyword) || (item.description.include? keyword))
      end
      applies_for_all
    end

    #AS Given an Array of Items return an Array of Items which match to the SearchRequest instance
    def get_matching_items(items)
      result= Array.new(items)
      result.delete_if{|item| !self.applies?(item)}
      result
    end

    #AS A little helper, to split the keyword-query up correctly.
    def self.splitUp(keywords)
      keywords.split(" ")
    end
  end
end


