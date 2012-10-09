require 'rubygems'
require 'sinatra'
require 'haml'
require 'controllers/main'
require 'controllers/authentication'
require 'controllers/item'
require 'controllers/change_password'
require 'models/user'
require 'models/item'
require 'models/data_overlay'

class App < Sinatra::Base

  use Authentication
  use Main
  use Item
  use ChangePassword

  enable :sessions
  set :show_exceptions, false
  set :public_folder, 'app/public'

  configure :development do
    #now use the DataOverlay
    overlay = Models::DataOverlay.instance

    user3 = overlay.new_user "Darth Vader", "pw Darth Vader"
    overlay.new_item "Death Star", 10000, "Big ass space ship", user3, true
    overlay.new_item "Storm Trooper", 25, "Do you already own one?", user3, false
    overlay.new_item "Dark Side of the Force", 10, "UNLIMITED POWER!!!", user3, false

    user2 = overlay.new_user "ese", "pw ese"
    overlay.new_item "Nyan Cat", 80, "The ultimate internet cat", user2, true
    overlay.new_item "Overly attached girlfriend", 0, "Take it, it's for free!!!", user2, true

    user4 = overlay.new_user "Steve", "pw Steve"
    overlay.new_item "Dirt", 1, "Minecraft :D", user4, true
    overlay.new_item "Diamond Pickaxe", 75, "Minecraft :D", user4, false

    user = overlay.new_user "Hat man", "pw Hat man"
  end
end

App.run!