require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'
require_relative '../app/models/item'
require_relative '../app/models/auction'
require_relative '../app/models/bid'
require_relative '../app/helpers/image_helper'

class AuctionTest < Test::Unit::TestCase
  include Models

  def setup
    @params = {}
    @params[:bid] = 8
    @params[:increment] = "2"
    @params[:minimal] = "5"
    @params[:description] = "test it"
    @params[:image] = nil
    @params[:year] = "2012"
    @params[:month] = "12"
    @params[:day] = "21"
    @params[:hour] = "12"

    @user1 = User.new("him", "Him", "qwertzuiop", "user1@mail.ch", "none1")
    @user2 = User.new("you", "You", "qwertzuiop", "user2@mail.ch", "none2")
    @item = Item.new("Nothing", 20, @user1, "none")
    @auction = Auction.new(@user1, @item, @params)
  end

  def test_create_auction
    assert(DataOverlay.instance.include?(@item.id))
    assert(@item.id == @auction.id)
    assert(@item.state == :auction)
  end

  def test_delete_auction
    DataOverlay.instance.delete_auction(@auction)
    assert_equal(DataOverlay.instance.include?(@item.id), false)
  end

  def test_new_bid
    @user2.give_bid(@auction, 8)
    bid = Item.validate_price(@params[:bid])
    assert(@auction.get_current_bid == bid)
  end
end