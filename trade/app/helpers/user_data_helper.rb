require_relative '../models/trade_exception'

class UserDataHelper

  def self.login name, password
    @data = Models::DataOverlay.instance
    user = @data.user_by_name name
    if user.nil?
      raise TradeException, "User not found!"
    end

    user.authenticate(password)
  end

  def self.register params
    #PS check some stuff
    self.register_checks(params)

    image = ImageHelper.save(params[:image],"#{settings.public_folder}/images/users")
    Models::User.new(params[:username], params[:display_name], params[:passwd], params[:email], params[:interests], image)
  end

  #PS check for required fields and contents
  def self.register_checks params
    data = Models::DataOverlay.instance

    unless params[:passwd] == params[:passwd_repetition]
      raise TradeException, "Passwords must be identical!"
    end

    if data.user_exists?(params[:username])
      raise TradeException, "Username already exists"
    end

    if data.user_display_name_exists?(params[:display_name])
      raise TradeException, "Display name already exists."
    end
  end
end