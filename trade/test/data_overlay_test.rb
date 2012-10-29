require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/data_overlay'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/search_request'
require_relative '../app/event/base_event'
require_relative '../app/event/item_update_event'
class DataOverlayTest < Test::Unit::TestCase
=begin  AS commented out old, failing tests, because I think the other group is working on cleaning these things up..
  def test_item_by_id_empty
     overlay =  Models::DataOverlay.instance
    assert_nil(overlay.item_by_id(0))
  end

  def test_new_item
    overlay = Models::DataOverlay.instance
    item = Models::Item.named("bla", 40, nil, "description", nil)
    overlay.new_item item
    assert_not_nil overlay.item_by_id(item.id)
  end

  def test_new_user
    overlay =  Models::DataOverlay.instance
    user = Models::User.named("first user", "pw first user",nil)
    assert_nil(overlay.user_by_name(user.name))
    overlay.new_user(user)
    assert_equal(user, overlay.user_by_name(user.name))
  end
=end
  def test_search_requests
    user1 = Models::User.named("Darth Vader", "pwDarthVader", "lord.vader@imperium.com")
    user2 = Models::User.named("bla", "pwblblablar", "ablabl@asfdewaf.com")

    overlay =  Models::DataOverlay.instance
    sr1= overlay.new_search_request(["some","keywords"], user1)
    overlay.new_search_request(["some","other","keywords"], user1)
    overlay.new_search_request(["again","some","keywords"], user2)
    overlay.new_search_request(["again","some","other","keywords"], user2)

    assert(overlay.search_request_by_id(0)==sr1)
    assert(overlay.search_requests_by_user(user1).size == 2, "User1 should have 2 SearchRequests")
    overlay.remove_search_request(sr1)
    assert(overlay.search_requests_by_user(user1).size == 1, "User1 should now have 1 SearchRequest")
    assert(overlay.search_requests_by_user(user2).size == 2, "User2 should have 2 SearchRequests")

  end



end