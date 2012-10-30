require "digest/md5"
require_relative "trade_exception"

module Models

  class Password

    attr_accessor :hash, :salt

    def self.make(passwd)
      unless self.passwd_valid?(passwd)
        raise TradeException, "Password is invalid"
      end
      self.new(passwd)
    end

    def initialize(passwd)
      create_salt()
      self.hash=encrypt(passwd)
    end

    #AS Checks if the given password is correct.
    def authenticate(passwd)
      unless self.hash == encrypt(passwd)
        raise TradeException, "Wrong password!"
      end

    end

    #AS Checks if a password is valid
    def self.passwd_valid?(password)
      !password.nil? and (password.length > 5 and password.match('^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).*$')) or password.length > 9
      #true
    end

    private
    #AS Hashes the given password + the previously created salt
    private
    def encrypt(passwd)
      Digest::MD5.hexdigest(self.salt + passwd)
    end

    #AS Creates the salt (which basically is a random string which is added to the password before hashing to prevent rainbow table attacks)
    def create_salt()
      size=10
      pool = ('a'..'z').to_a + ('0'..'9').to_a
      self.salt= (1..size).collect{|a| pool[rand(pool.size)]}.join
    end
  end
end