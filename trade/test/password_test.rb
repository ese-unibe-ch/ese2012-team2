require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/user'


class PasswordTest < Test::Unit::TestCase

  def accept_correct_passwd

    user = Models::User.named("Test", "passwd", "ese@ese.unibe.ch")

    assert(User.authenticated?("passwd"))
  end

  def decline_incorrect_passwd

    user = Models::User.named("Test", "passwd", "ese@ese.unibe.ch")

    assert(!User.authenticated?("qasswd"))
  end

end
