require 'test/unit'
require '../app/models/user'
require '../app/models/item'

class ItemTest < Test::Unit::TestCase

  def test_item_name
    name = "Item1"
    price = "10"
    item = Item.named(name, price)
    assert(item.name == name)
  end

  def test_item_price
    name = "Item1"
    price = "10"
    item = Item.named(name, price)
    assert(item.price == price)
  end

  def test_item_active
    item1 = Store::Item.named("Item1", 10)
    item2 = Store::Item.named("Item2", 5)

    item1.active = false
    item2.active=true

    assert(!item1.active)
    assert(item2.active)
  end

  def test_item_owner
    item1 = Store::Item.named("Item1", 10)
    item2 = Store::Item.named("Item2", 5)

    user = Store::User.named("John")
    item1.owner= user

    assert(item1.owner==user)
    assert(item2.owner==nil)
  end
end
