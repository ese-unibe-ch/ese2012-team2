require 'rubygems'
require 'bundler'
# This actually requires the bundled gems
Bundler.require

require_relative 'controllers/main'
require_relative 'controllers/authentication'
require_relative 'controllers/item_controller'
require_relative 'controllers/change_password'
require_relative 'controllers/reset_password'
require_relative 'controllers/base_controller'
require_relative 'controllers/base_secure_controller'
require_relative 'models/user'
require_relative 'models/item'
require_relative 'models/data_overlay'

class App < Sinatra::Base

  use Authentication
  use ResetPassword
  use Main
  use ItemController
  use ChangePassword

  enable :sessions
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public") }

  configure :development do
    #now use the DataOverlay
    overlay = Models::DataOverlay.instance
    user1 = overlay.new_user "Hat_man", "Hatman", "pwHatman", "hatman@udontsay.org", "Hats"
    overlay.new_item "Ghastly gibus", 10, "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.", user1, :active
    overlay.new_item "Ye olde baker boy", 15, "aslkghdk jfghöa dkfhgsödkjghsöd kjfhgsödkhgös dhsödlkjghös fklgjhsdkljg fsödlkgjh ösflkg hjs fklöghjsödkl gfjsödkljghösdklfgjhk lösfgh  jklösf jghklö sfgjhöfljghl öfgjhlösfjghslöfk jhöe rnbizrötklgh jaöitjsdbkög sdk lzh jskjödgh aköghp", user1, :active

    user3 = overlay.new_user "Darth_Vader", "Darth Vader", "pwDarthVader", "lord.vader@imperium.com", "Force"
    overlay.new_item "Death Star", 10000, "Big ass space ship", user3, :active
    overlay.new_item "Storm Trooper", 25, "Do you already own one?", user3
    overlay.new_item "Dark Side of the Force", 10, "UNLIMITED POWER!!!", user3, :active

    user2 = overlay.new_user "ese", "Ese", "pwese", "kenneth.radunz@web.de", "Computer science and stuff"
    overlay.new_item "Nyan Cat", 80, "The ultimate internet cat", user2, :active
    overlay.new_item "Overly attached girlfriend", 0, "Take it, it's for free!!!", user2, :active

    user4 = overlay.new_user "Steve", "Steve", "pwSteve", "steve@myblock.org", "Blocks o.O"
    overlay.new_item "Dirt", 1, "Minecraft :D", user4, :active
    overlay.new_item "Diamond Pickaxe", 75, "Minecraft :D", user4
  end
end

App.run!