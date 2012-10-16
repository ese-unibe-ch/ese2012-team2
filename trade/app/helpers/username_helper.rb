class UsernameHelper

  def self.remove_white_spaces(display_name)
    while(display_name.start_with?(" "))
      display_name = display_name.reverse.chop.reverse
    end

    while(display_name.end_with?(" "))
      display_name = display_name.chop
    end
    display_name
  end


end