require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/trade_exception'

class UserTest < Test::Unit::TestCase

  def setup
    @user = Models::User.new("Darth Vader", "DarthVader", "pwDarthVader", "lord.vader@imperium.com", "")
    @d_star = Models::Item.new("Death Star", 50, @user, "Big ass space ship", :active)
    @d_star2 = Models::Item.new("Death Star 2", 50, @user, "Big ass space ship")
    @org = Models::Organization.new("the Test", "none", @user, nil)
    @d_star3 = Models::Item.new("Death Star 2", 50, @org, "Big ass space ship", :active)
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
    assert_nothing_raised { @user.authenticate("pwDarthVader") }
  end

  def test_authenticated_fail
    assert_raise(TradeException) { @user.authenticate("pwDarthder") }
  end

  def test_buy
    assert_nothing_raised { @user.buy(@d_star3) }
    assert(@user.items.include?(@d_star3))
  end

  def test_fail_buy_own
    assert_raise(TradeException) { @user.buy(@d_star) }
  end

  def test_buy_for_organization
    @user.working_for = @org
    @user.buy(@d_star)
    assert(@org.items.include?(@d_star))
    assert(!@user.items.include?(@d_star))
  end

  def test_active_items
    assert(@user.active_items.include?(@d_star))
    assert(!@user.active_items.include?(@d_star2))
  end

  def test_all_items
    assert(@user.items.include?(@d_star))
    assert(@user.items.include?(@d_star2))
  end

  def test_confirm_receipt
     @user.buy(@d_star3)
     assert_equal(100, @org.credits)
     assert_equal(50, @user.credits)
     assert_nothing_raised { @user.confirm_receipt(@d_star3) }
     assert_equal(150, @org.credits)
  end

  def test_receipt_fail_owner
    @org.buy(@d_star)
    assert_raise(TradeException) { @user.confirm_receipt(@d_star)}
  end

  def test_receipt_fail_state
    assert_raise(TradeException) { @user.confirm_receipt(@d_star)}
  end

  def test_confirm_receipt_org
    @user.working_for = @org
    @user.buy(@d_star)
    assert_nothing_raised { @user.confirm_receipt(@d_star) }
  end

end
