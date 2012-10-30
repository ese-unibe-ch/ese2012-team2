require "digest/md5"
require_relative "password"
require_relative "trader"
module Models
  class User  < Models::Trader

    attr_accessor :name, :display_name, :password, :image, :email, :interests, :working_for

    #SH Creates a new user with his name
    def self.named(name, display_name, passwd, email, interests)
     return self.new(name, display_name, passwd, email, interests)
    end

    #AS Implements buying for an organization (Override)
    def buy(item)
      if working_for.nil?
        super
      else
        working_for.buy(item)
      end
    end

    #AS Checks if a password is valid (criteria need to be defined - at the moment it's just a "not-empty-test")
    def self.passwd_valid?(password)
      !password.nil? and password.length > 7 and password.match('^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).*$')
      #true
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
      @organization_request.push organization
    end

    def organization_request
      @organization_request
    end

    #SH Returns the name of the user
    def to_s
      self.name
    end

    #AS Sets the password.
    def set_passwd(passwd)
      self.passwd_hash= encrypt(passwd)
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