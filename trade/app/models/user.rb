require "digest/md5"
require_relative "password"
require_relative "trader"
require_relative "trade_exception"
module Models
  class User  < Models::Trader

    attr_accessor :password, :email, :working_for
    attr_reader :organization_request, :wish_list

    #AS Implements buying for an organization (Override)
    def buy(item)
      if working_for.nil?
        super
      else
        working_for.buy(item)
      end
    end

    def give_bid(auction, bid)
      if working_for.nil?
        super
      else
        working_for.buy(item)
      end
    end

    def organizations
      self.overlay.organizations_by_user(self)
    end

    def confirm_receipt(item)
      unless item.owner == self or item.owner == self.working_for
        raise TradeException, "Only the owner can confirm receipt!"
      end
      unless item.state == :pending
        raise TradeException, "Only pending items can be confirmed"
      end
      item.prev_owners.last.credits += item.price
      item.state = :inactive
    end

    #SH Setup standard values
    def initialize (name, display_name, passwd, email, interests, image=nil)
      self.credits=100
      self.credits_in_auction = 0
      if name.empty?
        raise TradeException, "Username must not be empty!"
      end
      self.name = name

      if display_name.empty?
        self.display_name = name
      else
        self.display_name = display_name
      end

      unless self.valid_email? email
        raise Exception, "Invalid email address!"
      end
      self.email = email

      self.password= Models::Password.make(passwd)
      self.interests= interests
      self.image = image
      @organization_request = Array.new()
      @wish_list = Array.new()

      self.overlay.add_user(self)
    end

    def add_wish item
      unless self.wish_list.include? item
        self.wishlist << item
      end
    end

    def remove_wish item
      self.wish_list.delete item
    end

    def valid_email? email
      email.match(/^[\w*\.?]+@(\w*\.)+\w{2,3}\z/)
    end

    def add_request(organization)
      self.organization_request.push organization
    end

    #SH Returns the name of the user
    def to_s
      self.name
    end

    #AS Checks if the given password is correct.
    def authenticate(passwd)
      self.password.authenticate(passwd)
    end

    def image_path
      if self.image.nil? then
        return "/images/users/default.png"
      else
        return "/images/users/" + self.image
      end
    end
  end
end