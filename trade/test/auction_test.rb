require 'test/unit'
require 'rubygems'
require 'require_relative'
require 'bundler'
Bundler.require
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/auction'
require_relative '../app/models/bid'
require_relative '../app/helpers/image_helper'
require_relative '../app/helpers/email_sender'

class AuctionTest < Test::Unit::TestCase
  include Models

  def setup
    @params = {}
    @params[:increment] = "2"
    @params[:minimal] = "5"
    @params[:description] = "test it"
    @params[:image] = nil
    @params[:year] = "2012"
    @params[:month] = "12"
    @params[:day] = "21"
    @params[:hour] = "12"

    @user1 = User.new("me", "Me", "qwertzuiop", "user1@mail.ch", "none1")
    @user2 = User.new("you", "You", "qwertzuiop", "user2@mail.ch", "none2")
    @user3 = User.new("him", "Him", "qwertzuiop", "user3@mail.ch", "none3")
    @item = Item.new("Nothing", 20, @user1, "none")
    @auction = Auction.new(@user1, @item, @params)
  end

  def test_create_auction
    assert(DataOverlay.instance.include?(@item.id))
    assert(@item.id == @auction.id)
    assert(@item.state == :auction)
    assert_equal(@auction.time_over?, false)
  end

  def test_delete_auction
    DataOverlay.instance.delete_auction(@auction)
    assert_equal(DataOverlay.instance.include?(@item.id), false)
  end

  def test_first_bid
    @user2.give_bid(@auction, 5)
    assert(@auction.get_current_bid == 5)
    assert(@user2.credits == 95)
    assert_equal(@auction.get_current_winner, @user2)
  end

  def test_new_bid
    @user2.give_bid(@auction, 15)
    assert(@auction.get_current_bid == 15)
    assert(@user2.credits == 85)
    assert(@auction.current_price == 5)
    assert_equal(@auction.get_current_winner, @user2)
  end

  def test_first_bid_too_small
    assert_raise(TradeException){@user2.give_bid(@auction, 4)}
    assert(@auction.get_current_bid == 0)
    assert(@user2.credits == 100)
    assert(@auction.current_price == 0)
    assert_equal(@auction.get_current_winner, nil)
  end

  def test_not_enough_money
    assert_raise(TradeException){@user2.give_bid(@auction, 101)}
    assert(@auction.get_current_bid == 0)
    assert(@user2.credits == 100)
    assert(@auction.current_price == 0)
    assert_equal(@auction.get_current_winner, nil)
  end

  def test_several_bids
    @user2.give_bid(@auction, 15)
    @user3.give_bid(@auction, 16)
    assert(@auction.get_current_bid == 16)
    assert(@user2.credits == 100)
    assert(@user3.credits == 84)
    assert(@auction.current_price == 17)
    assert_equal(@auction.get_current_winner, @user3)

    assert_raise(TradeException){@user2.give_bid(@auction, 16)}
    @user2.give_bid(@auction, 19)
    assert(@auction.get_current_bid == 19)
    assert(@user2.credits == 81)
    assert(@user3.credits == 100)
    assert(@auction.current_price == 18)
    assert_equal(@auction.get_current_winner, @user2)

    @user2.give_bid(@auction, 35)
    @user3.give_bid(@auction, 25)
    assert(@auction.get_current_bid == 35)
    assert(@user2.credits == 65)
    assert(@user3.credits == 100)
    assert(@auction.current_price == 27)
    assert_equal(@auction.get_current_winner, @user2)
  end

  def test_same_increment_and_minimal
    @params[:minimal] = 10
    @params[:increment] = 10

  end

  def test_time_over_no_bidder
    @auction.sell_to_current_winner
    assert(@item.state == :inactive)
  end

  def test_sell_to_current_winner
    @user3.give_bid(@auction, 15)
    @user2.give_bid(@auction, 25)
    @auction.sell_to_current_winner
    assert(@auction.get_current_winner == @user2)
    assert(@item.state == :pending)
    assert(@item.price == 17)
    assert(@user2.credits == 83)
    assert(@item.owner == @user2)
  end

  def test_validate_price_input
    @params[:minimal] = "test"
    assert_raise(TradeException){Auction.validate_minimal(@params[:minimal])}

    @params[:minimal] = -2
    assert_raise(TradeException){Auction.validate_minimal(@params[:minimal])}
  end

  def test_validate_increment_input
    @params[:increment] = "nothing"
    assert_raise(TradeException){Auction.validate_increment(@params[:increment])}

    @params[:increment] = -2
    assert_raise(TradeException){Auction.validate_increment(@params[:increment])}

    @params[:increment] = 0
    assert_raise(TradeException){Auction.validate_increment(@params[:increment])}
  end

  def test_image_path
    assert_equal("/images/items/default.png", @auction.image_path)
    @auction.image = "test.png"
    assert_equal("/images/items/test.png", @auction.image_path)
  end
end