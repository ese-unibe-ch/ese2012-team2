require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/comment'

class ItemTest < Test::Unit::TestCase

  def setup
    @user = Models::User.new("suti", "Suti", "qwertzuiop", "suti@patrick.ch", "none")
    @user1 = Models::User.new("suti1", "Suti1", "qwertzuiop", "suti@patrick1.ch", "none1")
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
     assert_equal("test Item", @item.to_s)
  end

  def test_comment
    assert_equal([],@item.comments)
    comment = Models::Comment.new("test text", @user1)
    comment1 = Models::Comment.new("test text1", @user1)
    @item.add_comment comment
    @item.add_comment comment1
    assert(@item.comments.include?(comment))
    assert_equal(comment1,@item.comments.pop)
  end

end
