require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'

class UserTest < Test::Unit::TestCase

  def setup
    @user = Models::User.named("Darth Vader", "DarthVader", "pwDarthVader", "lord.vader@imperium.com", "")
  end

 def test_to_s
   assert_equal("Darth Vader", @user.name)
 end

  def test_image_path
    assert_equal("/images/users/default.png", @user.image_path)
    @user.image = "test.png"
    assert_equal("/images/users/test.png", @user.image_path)
  end

  def test_email
    assert_equal("lord.vader@imperium.com", @user.email)
  end

  def test_authenticated
    assert(@user.authenticated?("pwDarthVader"))
  end

  def test_authenticated_fail
    assert(!@user.authenticated?("pwDarthder"))
  end

end
