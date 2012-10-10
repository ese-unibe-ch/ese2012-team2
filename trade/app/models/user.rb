require "digest/md5"

module Models
  class User
    @@users = Array.new #SH A list of all users
    attr_accessor :name, :credits, :passwd_hash, :image

    #SH Gets a user by its name
    def self.by_name(name)
      @@users.detect {|user| user.name == name }
    end

    #SH Returns all user
    def self.all
      @@users
    end

    #SH Creates a new user with his name
    def self.named(name, passwd)
     user = self.new(name, passwd)
     @@users.push(user)
     user
    end

    #AS Checks if a password is valid (criteria need to be defined - at the moment it's just a "not-empty-test")
    def self.passwd_valid?(password)
      !password.nil? and password.length > 7 and password.match('^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).*$')
    end

    #SH Setup standard values
    def initialize (name, passwd)
      self.credits=100
      self.name = name
      set_passwd(passwd)
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

    #AS Encrypts a given string and returns it.
    def encrypt(passwd)
      digest= Digest::MD5.digest(passwd)
      digest
    end

    #AS Sets the password.
    def set_passwd(passwd)
      self.passwd_hash= encrypt(passwd)
    end

    #AS Checks if the given password is correct.
    def authenticated?(passwd)
    self.passwd_hash==encrypt(passwd)
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