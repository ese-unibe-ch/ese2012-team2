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
    if email.include? '@' and email.include? '.'
      return true
    end
    return false
  end

  def self.login name, password
    @data = Models::DataOverlay.instance
    name = name
    password = password
    user = @data.user_by_name name
    if user.nil? || !user.authenticated?(password)
      raise "Wrong login"
    end
  end
end