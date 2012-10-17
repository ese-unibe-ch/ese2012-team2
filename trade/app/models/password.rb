require "digest/md5"

module Models
  #AS Represents a password
  class Password

    attr_accessor :hash, :salt

    def self.make(passwd)
       password= self.new(passwd)
    end

    def initialize(passwd)
      create_salt()
      self.hash=encrypt(passwd)
    end

    #AS Checks if the given password is correct.
    def authenticated?(passwd)
      self.hash == encrypt(passwd)
    end

    private
    #AS Hashes the given password + the previously created salt
    def encrypt(passwd)
      digest= Digest::MD5.hexdigest(salt+passwd)
    end

    #AS Creates the salt (which basically is a random string which is added to the password before hashing to prevent rainbow table attacks)
    def create_salt()
      size=10
      pool = ('a'..'z').to_a + ('0'..'9').to_a
      self.salt= (1..size).collect{|a| pool[rand(pool.size)]}.join
    end

  end
end