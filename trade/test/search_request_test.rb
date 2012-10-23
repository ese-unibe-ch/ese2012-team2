require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/search_request'
require_relative '../app/models/data_overlay'
require_relative '../app/models/user'
require_relative '../app/models/item'

class SearchRequestTest < Test::Unit::TestCase
  def test_should_match
    user = Models::User.named("Darth Vader", "pwDarthVader", "lord.vader@imperium.com")
    item= Models::Item.named("Death Star", 10000, user, "Big ass space ship")
    keywords = ["StAr", "DeAth", "ship"]
    sr= Models::SearchRequest.create(keywords, user)
    assert(sr.applies?(item), "Keywords should apply.")
  end

  def test_shouldnt_match
    user = Models::User.named("Darth Vader", "pwDarthVader", "lord.vader@imperium.com")
    item= Models::Item.named("Blub", 10000, user, "Big ass space ship")
    keywords = ["Star", "Death", "ship"]
    sr= Models::SearchRequest.create(keywords, user)
    assert(!sr.applies?(item), "Keywords shouldn't apply.")
  end

  def test_shouldnt_match
    user = Models::User.named("Darth Vader", "pwDarthVader", "lord.vader@imperium.com")
    item= Models::Item.named("Blub", 10000, user, "Big ass space ship")
    keywords = ["Star", "Death", "ship"]
    sr= Models::SearchRequest.create(keywords, user)
    assert(!sr.applies?(item), "Keywords shouldn't apply.")
  end

  def test_correct_items_should_match
    user = Models::User.named("Darth Vader", "pwDarthVader", "lord.vader@imperium.com")
    item1= Models::Item.named("blaaa Suchwort2  bla blabla", 10000, user, "bla bla Suchwort1 blaaa")
    item2= Models::Item.named("blaaa bla blabla", 10000, user, "bla bla Suchwort1 blaaa Suchwort2")
    item3= Models::Item.named("blaaa bla blabla", 10000, user, "bla bla Suchwort1 blaaa")

    keywords = ["SuchwORt1", "SUChwort2"]
    sr= Models::SearchRequest.create(keywords, user)
    assert(sr.get_matching_items([item1, item2, item3]) == [item1, item2], "item1 and item2 should be returned.")
  end

end