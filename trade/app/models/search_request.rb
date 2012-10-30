require_relative '../helpers/email_sender'

module Models
  #AS Models a search request. Create one by giving the keywords and check with applies? if an item matches.
  class SearchRequest
    attr_accessor :keywords, :user
    attr_reader :id

    @@count=0 #AS Static variable which stores the amount of SearchRequests created.

    def self.create(keywords, user)
      self.new(keywords, user)
    end

    def initialize(keywords, user)
      self.keywords=keywords
      self.user= user
      @id=@@count
      @@count+=1
    end

    #AS Check if a given Item matches to the SearchRequest instance
    def applies?(item)
      unless item.owner == self.user
        applies_for_all = true
        keywords.each do |keyword|
          if !applies_for_all
            break
          end
          applies_for_all= applies_for_all && ((item.name.downcase.include? keyword.downcase) || (item.description.downcase.include? keyword.downcase))
        end
        applies_for_all
      end
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

    #KR the Event calls this method, if fired
    def << args
      item = args[:item]
      if(self.applies? item)
         EmailSender.send_item_found(self.user, self, item)
      end
    end
  end
end


