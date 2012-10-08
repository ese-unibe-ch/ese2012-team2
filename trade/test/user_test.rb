require 'test/unit'
require 'app/models/user'
require 'app/models/item'

class UserTest < Test::Unit::TestCase

  def test_user_name
    name = "John"
    user = Models::User.named(name, "passwd")
    assert(user.name == name)
    assert(user.credits==100)
  end

  def test_standard_credits
    name = "John"
    user = Models::User.named(name, "passwd")
    assert(user.credits==100)
  end

  def test_custom_credits
    name = "John"
    credits = 153
    user = Models::User.named(name, "passwd")
    user.credits = credits
    assert(user.credits==credits)
  end

  def test_add_item
    user = Models::User.named("John", "passwd")
    item =  Models::Item.named("test", 10, user, nil)

    assert(user.items ==[item],"Add item test failed")
    assert(!user.items[0].active)
  end

  def test_active_item_list
    user = Models::User.named("John", "passwd")

    item1 = Models::Item.named("Item1", 10, user, nil)
    item2 = Models::Item.named("Item2", 5, user, nil)

    item1.active = false
    item2.active = true

    assert(user.active_items == [item2])
  end

  def test_user_buy_successful
    user1 = Models::User.named("Buyer", "passwd")
    user2 = Models::User.named("Seller","passwd")
    item1 = Models::Item.named("Item", 10, user2, nil)

    item1.active = true
    user1.buy(item1)

    assert(user1.items==[item1])
    assert(user1.credits== 90)
    assert(user2.items==[])
    assert(user2.credits==110)
  end

  def test_user_buy_not_enough_credits
    user1 = Models::User.named("Buyer", "passwd")
    user2 = Models::User.named("Seller", "passwd")
    item1 = Models::Item.named("Item", 101, user2, nil)

    item1.active = true
    user1.buy(item1)

    assert(user1.items==[])
    assert(user1.credits== 100)
    assert(user2.items==[item1])
    assert(user2.credits==100)
  end

  def test_user_buy_inactive_item
    user1 = Models::User.named("Buyer", "passwd")
    user2 = Models::User.named("Seller", "passwd")
    item1 = Models::Item.named("Item", 10, user2, nil)

    item1.active = false
    user1.buy(item1)

    assert(user1.items==[])
    assert(user1.credits== 100)
    assert(user2.items==[item1])
    assert(user2.credits==100)
  end

  def test_encryption
    user = Models::User.named("Peter", "passwd")
    assert(user.encrypt("abc 123") == user.encrypt("abc 123"), "Encrypting identical terms should result in an identical hash.")
    assert(user.encrypt("abc 321") != user.encrypt("abc 123"), "Not identical terms shouldn't have identical hashes.")
  end

  def test_authentication
      user= Models::User.named("Peter", "pi")
      assert(user.authenticated?("pi"), "Authentication with the correct password should work.")
      assert(!user.authenticated?("3.142"), "Authentication with the wrong password shouldn't work.")
  end

end