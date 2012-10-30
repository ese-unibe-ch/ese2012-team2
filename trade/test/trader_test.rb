require "test/unit"

class TraderTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @buyer = Models::Trader.new
    @seller = Models::Trader.new

    @buyer.credits = 100
    @seller.credits = 0

    @d_star = Models::Item.named("Death Star", 50, @seller, "Big ass space ship")
    @d_star.state = :active
  end

  def test_buy_success
    assert_equal(@buyer.credits, 100)
    assert_equal(@seller.credits, 0)

    @buyer.buy(@d_star)

    assert_equal(@buyer.credits, 50)
    assert_equal(@seller.credits, 0)
  end
end