require "test/unit"
require_relative "../app/models/organization"

class OrganizationTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @user = Models::User.named("suti", "Suti", "pwSuti", "suti@patrick.ch", "none")
    @user1 = Models::User.named("suti1", "Suti1", "pwSuti1", "suti@patrick1.ch", "none1")
    @org = Models::Organization.named("the Test", "none", @user)
  end

  # Fake test
  def test_name
    assert_equal("thetest", @org.name)
  end

  def test_display_name
    assert_equal("the Test", @org.display_name)
  end

  def test_admin
    assert_equal(@user, @org.admin)
  end

  def test_add_member
    @org.add_member(@user1)
    assert_equal(2, @org.members.length)
    assert(@org.members.include?@user1)
    assert(@org.members.include?@user)
  end

  def test_remove_member
    @org.add_member(@user1)
    @org.remove_member(@user1)
    assert(!@org.members.include?(@user1))
  end

  def test_remove_admin
    @org.remove_member(@user)
    assert(@org.members.include?(@user))
  end

  def test_send_and_accept_request
     @org.send_request(@user1)
     @org.accept_request(@user1)
     assert(@org.members.include?(@user1))
  end

  def test_send_and_decline_request
    @org.send_request(@user1)
    assert(@org.pending_members.include?(@user1))
    @org.decline_request(@user1)
    assert(!@org.members.include?(@user1))
    assert(!@org.pending_members.include?(@user1))
  end

  def test_is_member
    assert(@org.is_member?(@user))
    assert(!@org.is_member?(@user1))
  end

  def test_image_path
    assert_equal("/images/organizations/default.png", @org.image_path)
    @org.image = "test.png"
    assert_equal("/images/organizations/test.png", @org.image_path)
  end

  def test_to_s
    assert_equal("the Test", @org.to_s)
  end
end