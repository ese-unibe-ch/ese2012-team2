require 'rubygems'
require 'bundler'
# This actually requires the bundled gems
Bundler.require

require 'app/controllers/main'
require 'app/controllers/authentication'
require 'app/controllers/item_controller'
require 'app/controllers/change_password'
require_relative 'models/user'
require_relative 'models/item'
require_relative 'models/data_overlay'

class App < Sinatra::Base

  use Authentication
  use Main
  use ItemController
  use ChangePassword

  enable :sessions
  set :show_exceptions, false
  set :public_folder, "app/public"

  configure :development do
    #now use the DataOverlay
    overlay = Models::DataOverlay.instance
    user1 = overlay.new_user "Hat man", "pw Hat man"
    overlay.new_item "Ghastly gibus", 10, "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.", user1, true
    overlay.new_item "Ye olde baker boy", 15, "aslkghdkjfghöadkfhgsödkjghsödkjfhgsödkhgösdhsödlkjghösfklgjhsdkljgfsödlkgjhösflkghjsfklöghjsödklgfjsödkljghösdklfgjhklösfghjklösfjghklösfgjhöfljghlöfgjhlösfjghslöfkjhöernbizrötklghjaöitjsdbkögsdklzhjskjödghaköghp", user1, true

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
  end
end

App.run!