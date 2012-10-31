require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/search_request'
require_relative '../app/models/data_overlay'
require_relative '../app/models/user'
require_relative '../app/models/item'

class SearchRequestTest < Test::Unit::TestCase

  def setup
    @user = Models::User.new("Darth Vader", "Darth Vader", "qwertzuiop", "lord.vader@imperium.com", "")
    @user_search = Models::User.new("verona", "Verona Feldbush", "qwertzuiop", "lord.vader@imperium.com", "")

    @d_star = Models::Item.new("Death Star", 10000, @user, "Big ass space ship")
    @blubb = Models::Item.new("Blub", 10000, @user, "Big ass space ship")
  end
  def test_should_applie
    keywords = ["StAr", "DeAth", "ship"]
    sr= Models::SearchRequest.create(keywords, @user_search)
    assert(sr.applies?(@d_star), "Keywords should apply.")
  end

  def test_shouldnt_match_1
    keywords = ["Star", "Death", "ship"]
    sr= Models::SearchRequest.create(keywords, @user_search)
    assert(!sr.applies?(@blubb), "Keywords shouldn't apply.")
  end

  def test_should_not_match_own_items
    keywords = ["Star", "Death", "ship"]
    sr= Models::SearchRequest.create(keywords, @user)
    assert(!sr.applies?(@d_star), "own item shouldn't match the user search'")
  end

  def test_correct_items_should_match
    @user = Models::User.new("Darth Vader", "Darth Vader", "pwDarthVader", "lord.vader@imperium.com", "")
    item1= Models::Item.new("blaaa Suchwort2  bla blabla", 10000, @user, "bla bla Suchwort1 blaaa")
    item2= Models::Item.new("blaaa bla blabla", 10000, @user, "bla bla Suchwort1 blaaa Suchwort2")
    item3= Models::Item.new("blaaa bla blabla", 10000, @user, "bla bla Suchwort1 blaaa")

    keywords = ["SuchwORt1", "SUChwort2"]
    sr= Models::SearchRequest.create(keywords, @user_search)
    assert(sr.get_matching_items([item1, item2, item3]) == [item1, item2], "item1 and item2 should be returned.")
  end

  def test_query_split
    splitted = Models::SearchRequest.splitUp("one two three  ")
    assert_equal(splitted.length, 3)
    assert_equal(splitted[0], "one")
    assert_equal(splitted[1], "two")
    assert_equal(splitted[2], "three")
  end

end