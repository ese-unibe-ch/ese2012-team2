require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/tag'

class TagTest < Test::Unit::TestCase

  def setup
    @user = Models::User.new("user", "user", "qwertzuiop", "user@user.ch", "none")
    @item = Models::Item.new("test", 10, @user, "none")
  end

  def test_validity
    assert(Models::Tag.valid?("#Books"), "One valid hashtag should be allowed.")
    assert(!Models::Tag.valid?("#Books #SomeMoreBooks #AndOthers"), "Multiple hashtags shouldn't be allowed.")
    assert(!Models::Tag.valid?("b#lab##la"))
  end

  def test_extraction_from_string
    assert(Models::Tag.get_tag_names_from_string("#Books #SomeMoreBooks Osterhase #AndOthers").length==3)
    assert(Models::Tag.get_tag_names_from_string("#Books #SomeMoreBooks Osterhase #AndOthers")[1]=="#SomeMoreBooks")
  end



end
