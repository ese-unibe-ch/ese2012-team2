require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative '../app/models/password'


class PasswordTest < Test::Unit::TestCase

  def test_create_password
    pwd = Models::Password.make "testpw"
    assert_not_nil(pwd.hash)
    assert_not_nil(pwd.salt)
    assert_match(/[0-9a-z]{32}/, pwd.hash)
    assert_match(/[0-9a-z]{10}/, pwd.salt)
  end

  def test_accept_correct_passwd
    pwd = Models::Password.make "testpw"
    assert(pwd.authenticated?("testpw"))
  end

  def test_decline_incorrect_passwd
    pwd = Models::Password.make "testpw"
    assert(!pwd.authenticated?("testfghpw"))
  end

  def test_valid_pw
    pwd = Models::Password.make "testpw"
    assert(pwd.authenticated? "testpw" )
  end

  def test_invalid_pw
    pwd = Models::Password.make "testpw"
    assert(!pwd.authenticated?("testewfpw"))
  end

end
