require "digest/md5"
require_relative "password"
module Models
  class User
    @@users = Array.new #SH A list of all users
    attr_accessor :name, :display_name, :credits, :password, :image, :email, :interests

    #SH Gets a user by its name
    def self.by_name(name)
      @@users.detect {|user| user.name == name }
    end

    #SH Returns all user
    def self.all
      @@users
    end

    #SH Creates a new user with his name
    def self.named(name, display_name, passwd, email, interests)
     user = self.new(name, display_name, passwd, email, interests)
     @@users.push(user)
     user
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

    #SH Adds a new item
    def add_new_item(name, price, description, image=nil)
      Item.named(name, price, self, description, image)
    end


    #PS Deletes the item completely!
    def del_item(item)
      Item.delete_item(item)
    end

    #SH Checks whether the user can buy an item and then buys it
    def buy(item)
      if item.active
        if item.price<=self.credits
          self.credits -= item.price
          item.owner.credits += item.price
          item.owner = self
          item.active = false
        else
          return "credit error"
        end
      else
        return "item error"
      end

    end

    def items
      Models::Item.all.select {|item| item.owner == self}
    end

    #SH Returns a list of all active items of a user
    def active_items
      self.items.select {|item| item.active}
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