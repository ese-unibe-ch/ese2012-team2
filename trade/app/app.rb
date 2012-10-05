require 'rubygems'
require 'sinatra'
require 'haml'
require 'controllers/main'
require 'controllers/authentication'
require 'controllers/item'
require 'models/user'
require 'models/item'

class App < Sinatra::Base

  use Authentication
  use Main
  use Item

  enable :sessions
  set :show_exceptions, false
  set :public_folder, 'app/public'

  configure :development do
    user = Models::User.named("Hat man")
    user.add_new_item("Ghastly gibus", 10).active = true
    user.add_new_item("Ye olde baker boy", 15).active = true
    user.add_new_item("Noh Mercy", 14)
    user.add_new_item("Prussian Pickelhaube", 11).active  =true
    user.add_new_item("Troublemaker's tossle cap", 8).active  =true
    user.add_new_item("Hero's Hachimaki", 12)
    user.add_new_item("Sergeant's drill hat", 10).active  =true
    user.add_new_item("Handyman's Handle", 18).active  =true

    user2 = Models::User.named("ese")
    user2.add_new_item("Nyan Cat", 80).active = true
    user2.add_new_item("Pink Unicorn", 100)
    user2.add_new_item("Overly attached girlfriend", 0).active=true
    user2.add_new_item("Charizard", 75).active=true

    user3 = Models::User.named("Darth Vader")
    user3.add_new_item("Death star", 10000).active=true
    user3.add_new_item("Storm trooper", 25)
    user3.add_new_item("Force", 10).active = true

    user4 = Models::User.named("Steve")
    user4.add_new_item("Dirt", 1).active = true
    user4.add_new_item("Diamond Pickaxe", 75).active = true
    user4.add_new_item("Stone", 5).active = true
    user4.add_new_item("Redstone", 10).active = true
    user4.add_new_item("Log", 2).active = true
    user4.add_new_item("Sand", 1).active = true
    user4.add_new_item("Workbench", 3).active = true
  end


end

App.run!