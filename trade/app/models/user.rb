require "digest/md5"
require_relative "password"
require_relative "trader"
require_relative "trade_exception"
require_relative "coordinates"
module Models
  # a single user which extends the trader class
  class User < Models::Trader

    attr_accessor :password, :email, :working_for, :trackees, :state, :suspension_time, :street, :postal_code, :city, :country, :coordinates
    attr_reader :organization_request, :wish_list

    #AS Implements buying for an organization (Override) (ignore_working_for is for special cases, e.g. buying on request)
    def buy(item, quantity, ignore_working_for=false)
      if working_for.nil? || ignore_working_for
        super(item, quantity)
      else
        working_for.buy(item, quantity)
      end
    end



    # set a bid for an auction
    def give_bid(auction, bid)
      if working_for.nil?
        super
      else
        working_for.give_bid(auction, bid)
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
      self.add_activity "Confirmed receipt of #{item.name}."
    end

    #SH Setup standard values
    def initialize (name, display_name, passwd, email, interests, street=nil, postal_code=nil, city=nil, country=nil,image=nil)
      self.credits=100
      self.state=:active
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

      self.street = street
      self.postal_code = postal_code
      self.city = city
      self.country = country

      self.coordinates = Coordinates.by_address(street, postal_code, city, country)  unless street.nil? or postal_code.nil? or city.nil? or country.nil?

      self.image = image
      @organization_request = Array.new()
      @wish_list = Array.new()
      self.add_activity "User #{self.name} was created."
      self.overlay.add_user(self)
    end

    def add_wish item
      unless self.wish_list.include? item
        @wish_list << item
        self.add_activity("Added #{item.name} to wish list.")
      end
    end

    def remove_wish item
      if @wish_list.delete(item)
        self.add_activity("Removed #{item.name} from wish list.")
      end
    end

    def valid_email? email
      email.match(/^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/)
    end

    def add_request(organization)
      organization.add_activity "offered organization membership to #{self.display_name}"
      self.add_activity "received organization membership offer from #{organization.display_name}"
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

    def track(trackee)
      self.overlay.track(self, trackee)
    end

    def untrack(trackee)
      self.overlay.untrack(self, trackee)
    end

    def trackees
      self.overlay.trackees_by_user(self)
    end

    def tracked_activities
      self.overlay.activities_by_owners(self.trackees)
    end

    def organization_activities
       trackables = Array.new()
       self.organizations.each { |org|
          org.members.each { |member|
            unless member == self or trackables.include? member
               trackables.push member
            end
          }
          trackables.push org
       }
       self.overlay.activities_by_owners(trackables)
    end

    def track_id
      "user$#{self.name}"
    end

    def image_path
      if self.image.nil? then
        return "/images/users/default.png"
      else
        return "/images/users/" + self.image
      end
    end

    def expired?
      return false unless self.state == :suspended
      res = Time.diff(self.suspension_time, Time.now)
      return true if res[:minute] > 0 or res[:second] > 10
      false
    end

    def users_near_me(radius)
      near_users = Array.new()
      unless self.coordinates.nil?
        @data.all_users.each do |user|
          near_users.push(user) if not user == self and not user.coordinates.nil? and self.coordinates.distance(user.coordinates) < radius.to_f
        end
      end
      near_users
    end
  end
end