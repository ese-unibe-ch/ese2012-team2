require "digest/md5"
require_relative "password"
module Models
  class User

    attr_accessor :name, :display_name, :credits, :password, :image, :email, :interests

    #SH Creates a new user with his name
    def self.named(name, display_name, passwd, email, interests)
     return self.new(name, display_name, passwd, email, interests)
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
    end

    #SH Returns the name of the user
    def to_s
      self.name
    end

    #SH Checks whether the user can buy an item and then buys it
    def buy(item)
      if item.state == :active
        if item.price<=self.credits
          self.credits -= item.price
          #item.owner.credits += item.price
          item.take_ownership(self)
          item.state = :pending
        else
          return "credit error"
        end
      else
        return "item error"
      end
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