require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'

class ItemTest < Test::Unit::TestCase

  def setup
    @user = Models::User.named("suti", "Suti", "pwSuti", "suti@patrick.ch", "none")
    @user1 = Models::User.named("suti1", "Suti1", "pwSuti1", "suti@patrick1.ch", "none1")
    @item = Models::Item.named("test Item", 500, @user, "none")
  end

  def test_takeownership
    @item.take_ownership(@user1)
    assert_equal(1, @item.prev_owners.length)
    assert(@item.prev_owners.include?(@user))
    assert_equal(@user1, @item.owner)
  end

  def test_inactive_after_creation
   assert_equal(:inactive, @item.state)
  end

  def test_image_path
    assert_equal("/images/items/default.png", @item.image_path)
    @item.image = "test.png"
    assert_equal("/images/items/test.png", @item.image_path)
  end

  def test_to_s

  end

end
