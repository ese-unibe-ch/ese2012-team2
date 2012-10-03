require 'test/unit'
require '../app/store/user'
require '../app/store/item'

class UserTest < Test::Unit::TestCase

  def test_user_name
    name = "John"
    user = Store::User.named(name)
    assert(user.name == name)
    assert(user.credits==100)
  end

  def test_standard_credits
    name = "John"
    user = Store::User.named(name)
    assert(user.credits==100)
  end

  def test_custom_credits
    name = "John"
    credits = 153
    user = Store::User.named(name)
    user.credits = credits
    assert(user.credits==credits)
  end

  def test_add_item
    user = Store::User.named("John")
    item =  Store::Item.named("test", 10)
    user.add_item(item)
    assert(user.items ==[item],"Add item test failed")
    assert(!user.items[0].active)
  end

  def test_active_item_list
    user = Store::User.named("John")

    item1 = Store::Item.named("Item1", 10)
    item2 = Store::Item.named("Item2", 5)

    item1.active = false
    item2.active = true

    user.add_item(item1)
    user.add_item(item2)

    assert(user.item_list==[item2])
  end

  def test_user_buy_successful
    user1 = Store::User.named("Buyer")
    user2 = Store::User.named("Seller")
    item1 = Store::Item.named("Item", 10)
    user2.add_item(item1)
    item1.active = true
    user1.buy(user2, item1)

    assert(user1.items==[item1])
    assert(user1.credits== 90)
    assert(user2.items==[])
    assert(user2.credits==110)
  end

  def test_user_buy_not_enough_credits
    user1 = Store::User.named("Buyer")
    user2 = Store::User.named("Seller")
    item1 = Store::Item.named("Item", 101)
    user2.add_item(item1)
    item1.active = true
    user1.buy(user2, item1)

    assert(user1.items==[])
    assert(user1.credits== 100)
    assert(user2.items==[item1])
    assert(user2.credits==100)
  end

  def test_user_buy_inactive_item
    user1 = Store::User.named("Buyer")
    user2 = Store::User.named("Seller")
    item1 = Store::Item.named("Item", 10)
    user2.add_item(item1)
    item1.active = false
    user1.buy(user2, item1)

    assert(user1.items==[])
    assert(user1.credits== 100)
    assert(user2.items==[item1])
    assert(user2.credits==100)
  end
end