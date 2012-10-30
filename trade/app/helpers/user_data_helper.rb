require_relative '../models/trade_exception'

class UserDataHelper

  def self.remove_white_spaces(display_name)
    while(display_name.start_with?(" "))
      display_name = display_name.reverse.chop.reverse
    end

    while(display_name.end_with?(" "))
      display_name = display_name.chop
    end
    display_name
  end

  def self.right_email?(email)
    return self.matches_regex?(email, /^[\w*\.?]+@(\w*\.)+\w{2,3}\z/ )
  end

  def self.matches_regex?(string, regex)
    match = regex.match(string)
    return false unless match
    return (match[0] == string) unless match.nil?
  end

  def self.login name, password
    @data = Models::DataOverlay.instance
    name = name
    password = password
    user = @data.user_by_name name
    if user.nil? || !user.authenticated?(password)
      raise TradeException, "Wrong login"
    end
  end

  def self.register params
    data = Models::DataOverlay.instance
    #PS check some stuff
    self.register_checks(params)
    #PS create the new user
    new_user = data.new_user(params[:username], params[:display_name], params[:passwd], params[:email], params[:interests])
    new_user.image = ImageHelper.save(params[:image],"#{settings.public_folder}/images/users")
    new_user
  end

  #PS check for required fields and contents
  def self.register_checks params
    data = Models::DataOverlay.instance

    if params[:username] == "" || params[:display_name] == "" || params[:passwd] == "" || params[:email] == ""
      raise TradeException, "Data are missing."
    end

    unless Models::Password.passwd_valid?(params[:passwd])
      raise TradeException, "Your password is invalid."
    end

    if data.user_exists?(params[:username])
      raise TradeException, "User already exists."
    end

    unless UserDataHelper.right_email?(params[:email])
      raise TradeException, "Incorrect email address."
    end

    display_name = UserDataHelper.remove_white_spaces(params[:display_name])

    if data.user_display_name_exists?(display_name)
      raise TradeException, "Display name already exists."
    end
  end
end