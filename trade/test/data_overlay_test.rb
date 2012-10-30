require 'test/unit'
require 'rubygems'
require 'require_relative'
require 'bundler'
Bundler.require
require_relative '../app/models/data_overlay'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/search_request'
require_relative '../app/event/base_event'
require_relative '../app/event/item_update_event'
class DataOverlayTest < Test::Unit::TestCase

  def setup
    @overlay =  Models::DataOverlay.instance
  end

  def test_item_by_id_empty
    assert_nil(@overlay.item_by_id(0))
  end

  def test_search_requests

=begin
    overlay =  Models::DataOverlay.instance
    user1 = overlay.new_user("vader", "Darth Vader", "pwDarthVader", "lord.vader@imperium.com", nil)
    user2 = overlay.new_user("bla", "Mr Blaaa", "pwblblablar", "ablabl@asfdewaf.com", nil)
    sr1= overlay.new_search_request(["some","keywords"], user1)
    overlay.new_search_request(["some","other","keywords"], user1)
    overlay.new_search_request(["again","some","keywords"], user2)
    overlay.new_search_request(["again","some","other","keywords"], user2)

    assert(overlay.search_request_by_id(0)==sr1)
    assert(overlay.search_requests_by_user(user1).size == 2, "User1 should have 2 SearchRequests")
    overlay.remove_search_request(sr1)
    assert(overlay.search_requests_by_user(user1).size == 1, "User1 should now have 1 SearchRequest")
    assert(overlay.search_requests_by_user(user2).size == 2, "User2 should have 2 SearchRequests")
=end

  end



end