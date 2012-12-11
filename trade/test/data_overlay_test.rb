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
    @user = Models::User.new("Darth Vader", "DarthVader", "pwDarthVader", "lord.vader@imperium.com", "")
    @d_star = Models::Item.new("Death Star", 50, @user, "Big ass space ship")
    @d_star.state = :active
  end

  def test_active_items
    for item in @overlay.active_items
      assert(item.state == :active || item.state == :auction)
    end
  end

  def test_search_requests
    begin
      overlay =  Models::DataOverlay.instance
      user1 = Models::User.new("vader", "Darth Vader", "pwDarthVader", "lord.vader@imperium.com", nil)
      user2 = Models::User.new("bla", "Mr Blaaa", "pwblblablar", "ablabl@asfdewaf.com", nil)
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

  def test_delete_item
    @d_star.state = :inactive
    @overlay.delete_item(@d_star)
    assert_nil(@items, "the list should be empty")
  end

  def test_all_items
    assert(@overlay.all_items.include?(@d_star), "the item should exist")
  end

  def test_delete_user
    @d_star.state = :inactive
    @overlay.delete_user(@user)
    assert_nil(@users, "the list should be empty")
  end

  def test_all_users
    assert(@overlay.all_users.include?(@user), "the user should exist")
  end

  def test_user_display_name_existence
    display_name = "Moon"
    assert(!@overlay.user_display_name_exists?(display_name), "the display_name shouldn't exist")
  end

  def test_user_existence
    user2 =  Models::User.new("Darth Vader", "DarthVader", "pwDarthVader", "lord.vader@imperium.com", "")
    assert(@overlay.user_exists?(user2.name), "the user should exist")
  end

  def test_organization_existence
    organization = Models::Organization.new("Team2", " ", "ese", "")
    assert(@overlay.organization_exists?(organization.name), "the organization should exist")
  end

end