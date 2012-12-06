require_relative '../helpers/email_sender'
require 'text'

module Models
  #AS Models a search request. Create one by giving the keywords and check with applies? if an item matches.
  class SearchRequest
    attr_accessor :keywords, :user, :tags
    attr_reader :id

    @@count=0 #AS Static variable which stores the amount of SearchRequests created.

    def self.create(keywords, user)
      self.new(keywords, user)
    end

    def initialize(keywords_and_tags, user)
      self.tags= Tag.get_tags_from_array(keywords_and_tags)
      self.keywords=keywords_and_tags.delete_if{|word| Tag.valid?(word)}
      self.user= user
      @id=@@count
      @@count+=1
    end

    #AS Check if a given Item matches to the SearchRequest instance
    def applies?(item)
      unless item.owner == self.user
        tags_apply?(item) && !check_if_item_is_close_enough(item).nil?
      end
    end

    #AS Checks the list of items for the ones, which are below a particular treshold regarding the levenshtein distance of the best matching
    # word in the items name or description to every keyword. The items are sorted regarding their "overall levenshtein distance".
    def get_close_items(items)
      items_and_distances=Array.new
      items.each do |item|
        unless item.owner == self.user
          item_and_distance= check_if_item_is_close_enough(item)
          unless item_and_distance.nil?
            items_and_distances.push(item_and_distance)
          end
        end
      end
      items_and_distances.sort!{|x,y| x[1] <=> y[1]}
      items_and_distances.each{|x| x.each{|y| print y}}
      items_and_distances.collect{|x| x[0]}
    end

    #AS Checks if an item is close enought (using the levenshtein distance as already described under "get_close_items"). If yes: [item, distance] is returned, else: nil is returned.
    def check_if_item_is_close_enough(item)
      threshold= 1
      overall_min_distance= threshold
      keywords.each do |keyword|
         keyword= keyword.downcase
         minimal_distance= [get_minimal_distance(keyword, item.name.downcase), get_minimal_distance(keyword, item.description.downcase)].min
         overall_min_distance= [overall_min_distance, minimal_distance].min
         if(minimal_distance>threshold)
           return nil
         end
      end
      return [item, overall_min_distance]
    end

    #AS Gets the best (minmal) levenshtein distance from keyword and the optimal "word" (splitted by empty spaces) of the string.
    def get_minimal_distance(keyword, string)
      min= string.length+keyword.length #the distance can't possibly be bigger..
      string.split(" ").each do |word|
        min= [min, Text::Levenshtein.distance(keyword, word)].min
      end
      min
    end

    #AS Gets the sum of the levensthein distances of a keyword and each word of a string. (This metric helps with sorting)
    def get_overall_distance(keyword, string)
      sum= 0
      string.split(" ").each do |word|
        sum+= Text::Levenshtein.distance(keyword, word)
      end
      sum
    end

    def tags_apply?(item)
       applies_for_all = true
       tags.each do |tag|
        applies_for_all= applies_for_all && tag.item_applies?(item)
       end
       applies_for_all
    end

    #AS Given an Array of Items return an Array of Items which match to the SearchRequest instance
    def get_matching_items(items)
      result= get_close_items(items)
      result.delete_if{|item| !self.tags_apply?(item)}
      result.each{|item| print item.name}
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


