require_relative '../models/trade_exception'

class UserDataHelper

  def self.edit_user params, active_user
    display_name = params[:display_name]

    if display_name != active_user.display_name and @data.user_display_name_exists?(display_name)
      raise TradeException, "Displayname already exists."
    end

    active_user.display_name = display_name
    image = ImageHelper.save(params[:image], "#{settings.public_folder}/images/users")
    if image
      active_user.image = image
    end
    active_user.interests = params[:interests]
  end

  def self.login name, password
    @data = Models::DataOverlay.instance
    user = @data.user_by_name name
    if user.nil?
      raise TradeException, "User not found!"
    end
    user.state = :active
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

  def self.can_suspend?(user)
    #TODO check for active items
    return false if @data.active_items_by_trader(user).length > 0
    #TODO check for memberships
    return false if @data.organizations_by_user(user).length > 0
    #TODO check for open auctions
    return false if @data.all_auctions().select{|auction| auction.item.user == user}.length > 0
    #TODO check for leading bids
    return false if @data.all_auctions().select{|auction| auction.get_current_winner == user}.length > 0
    #ELSE
    true
  end

  def self.delete_user(user)
    items = @data.items_by_trader(user)
    for item in items
      @data.remove_trackers_by_trackee item
      @data.delete_item item
    end
    @data.remove_trackers_by_trackee user
    @data.delete_user user
  end
end