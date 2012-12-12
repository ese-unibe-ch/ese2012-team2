require "test/unit"

class TraderTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @buyer = Models::Trader.new
    @seller = Models::Trader.new

    @buyer.credits = 100
    @seller.credits = 0

    @d_star = Models::Item.new("Death Star", 50, @seller, "Big ass space ship", :active)
  end

  def test_buy_success
    assert_equal(@buyer.credits, 100)
    assert_equal(@seller.credits, 0)

    @buyer.buy(@d_star, 1)

    assert_equal(@buyer.credits, 50)
    assert_equal(@seller.credits, 0)
  end

  def test_buy_fail_credits
    @buyer.credits = 0
    assert_raise(TradeException) { @buyer.buy(@d_star, 1) }
  end

  def test_buy_fail_state
    @d_star.state = :inactive
    assert_raise(TradeException) { @buyer.buy(@d_star, 1) }
    @d_star.state = :pending
    assert_raise(TradeException) { @buyer.buy(@d_star, 1) }
  end

  def test_items
    assert_equal(1, @seller.items.length)
    assert(@seller.items.include?(@d_star))
  end
end