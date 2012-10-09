require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/data_overlay'
require_relative '../app/models/user'
require_relative '../app/models/item'

class DataOverlayTest < Test::Unit::TestCase
  def test_item_by_id_empty
     overlay =  Models::DataOverlay.instance
    assert_nil(overlay.item_by_id(0))
  end

  def test_new_item
    overlay = Models::DataOverlay.instance
    item = Models::Item.named("bla", 40, nil, "description")
    overlay.new_item item
    assert_not_nil overlay.item_by_id(item.id)
  end

  def test_new_user
    overlay =  Models::DataOverlay.instance
    user = Models::User.named("first user", "pw first user")
    assert_nil(overlay.user_by_name(user.name))
    overlay.new_user(user)
    assert_equal(user, overlay.user_by_name(user.name))
  end
end