require 'test/unit'
require '../app/models/user'
require '../app/models/item'

class ItemTest < Test::Unit::TestCase

  def test_item_name
    name = "Item1"
    price = "10"
    user = Models::User.named("Test")
    item = Models::Item.named(name, price, nil, user)
    assert(item.name == name)
  end

  def test_item_price
    name = "Item1"
    price = "10"
    user = Models::User.named("Test")
    item = Models::Item.named(name, price, nil, user)
    assert(item.price == price)
  end

  def test_item_active
    user = Models::User.named("Test")
    item1 = Models::Item.named("Item1", 10, nil, user)
    item2 = Models::Item.named("Item2", 5, nil, user)

    item1.active = false
    item2.active=true

    assert(!item1.active)
    assert(item2.active)
  end

  def test_item_owner
    user = Models::User.named("Test")
    item1 = Models::Item.named("Item1", 10, nil, user)
    item2 = Models::Item.named("Item2", 5, nil, nil)


    assert(item1.owner==user)
    assert(item2.owner==nil)
  end

  def  test_id_generation
    #TODO PS are id's generated correctly?
  end

  def get_item_by_id
    #TODO PS does item.by_id fetch the expected item?
  end
end
