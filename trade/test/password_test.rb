require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/password'


class PasswordTest < Test::Unit::TestCase

  def test_create_password
    pwd = Models::Password.make "qwertzuiop"
    assert_not_nil(pwd.hash)
    assert_not_nil(pwd.salt)
    assert_match(/[0-9a-z]{32}/, pwd.hash)
    assert_match(/[0-9a-z]{10}/, pwd.salt)
  end

  def test_valid_short_pw
    assert_nothing_raised() { Models::Password.make "Hello8"}
  end

  def test_accept_correct_passwd
    pwd = Models::Password.make "qwertzuiop"
    assert_nothing_raised { pwd.authenticate("qwertzuiop") }
  end

  def test_decline_incorrect_passwd
    pwd = Models::Password.make "qwertzuiop"
    assert_raise(TradeException) { pwd.authenticate("qwertzuioergfr") }
  end

  def test_invalid_pw_creation
    assert_raise(TradeException) { Models::Password.make "qweuiop" }
  end

end
