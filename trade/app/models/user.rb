require "digest/md5"
require_relative "password"
require_relative "trader"
module Models
  class User  < Models::Trader

    attr_accessor :password, :email, :working_for
    attr_reader :organization_request

    #SH Creates a new user with his name
    def self.named(name, display_name, passwd, email, interests)
     user = self.new(name, display_name, passwd, email, interests)
     user.overlay.add_user(user)
    end

    #AS Implements buying for an organization (Override)
    def buy(item)
      if working_for.nil?
        super
      else
        working_for.buy(item)
      end
    end

    #SH Setup standard values
    def initialize (name, display_name, passwd, email, interests)
      self.credits=100
      self.name = name
      self.display_name = display_name
      self.email = email
      self.password= Models::Password.make(passwd)
      self.interests= interests
      @organization_request = Array.new()
    end

    def add_request(organization)
      self.organization_request.push organization
    end

    #SH Returns the name of the user
    def to_s
      self.name
    end

    #AS Checks if the given password is correct.
    def authenticated?(passwd)
      self.password.authenticated?(passwd)
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