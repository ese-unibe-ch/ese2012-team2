require_relative "search_request"
require_relative "trade_exception"

module Models

  class SimilarItemRequest < Models::SearchRequest

    attr_accessor :item

    def initialize(item)
      @item = item
      keywords = "#{item.name} "
      item.tags.each { |tag |
        keywords = "#{keywords} #{tag}"
      }
      keywords_list = Models::SearchRequest.splitUp(keywords)
      super(keywords_list, nil)
      @hits = 0
    end

    #AS Check if a given Item matches to the SearchRequest instance
    def applies?(item)
      unless item == self.item
        tags_apply?(item) || keywords_apply?(item)
      end
    end

    def keywords_apply?(item)
      applies = false
      keywords.each do |keyword|
        applies = applies || self.keyword_applies?(item, keyword)
      end
      applies
    end

    def find_similar_items(items)

    end

    def keyword_applies?(item, keyword)
      name = item.name.downcase
      key = keyword.downcase
      if name == key
        @hits += 3
        return true
      end
      if name.include? key
        @hits += 1
        return true
      end
      return false
    end

    def tags_apply?(item)
      applies = false
      tags.each do |tag|
        if tag.item_applies?(item)
          applies = true
          @hits += 5
        end
      end
      applies
    end

    #PS overridden to deactivate this functionality
    def << args
      raise TradeException, "not supported"
    end

  end
end