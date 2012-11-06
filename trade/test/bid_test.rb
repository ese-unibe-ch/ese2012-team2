require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/trade_exception'
require_relative '../../trade/app/models/auction'
require_relative '../../trade/app/models/bid'

class BidTest < Test::Unit::TestCase

  def setup
    @user = Models::User.new("Darth Vader", "DarthVader", "pwDarthVader", "lord.vader@imperium.com", "")
    @d_star = Models::Item.new("Death Star", 50, @user, "Big ass space ship", :active)
    @d_star2 = Models::Item.new("Death Star 2", 50, @user, "Big ass space ship")
    @org = Models::Organization.new("the Test", "none", @user, nil)
    @d_star3 = Models::Item.new("Death Star 2", 50, @org, "Big ass space ship", :active)
    @auction = Models::Auction.new(@user,@d_star,:param)

  end
end
end
