require 'rubygems'
require 'sinatra'
require 'haml'
require 'app/controllers/main'
require 'app/controllers/authentication'
require 'app/controllers/item'
require 'app/models/user'
require 'app/models/item'

class App < Sinatra::Base

  use Authentication
  use Main
  use Item

  enable :sessions
  set :show_exceptions, false
  set :public_folder, 'app/public'

  configure :development do
    user = Models::User.named("Hat man", "pw Hat man")
    user.add_new_item("Ghastly gibus", 10, "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.").active = true
    user.add_new_item("Ye olde baker boy", 15, "aslkghdkjfghöadkfhgsödkjghsödkjfhgsödkhgösdhsödlkjghösfklgjhsdkljgfsödlkgjhösflkghjsfklöghjsödklgfjsödkljghösdklfgjhklösfghjklösfjghklösfgjhöfljghlöfgjhlösfjghslöfkjhöernbizrötklghjaöitjsdbkögsdklzhjskjödghaköghp").active = true
    user.add_new_item("Noh Mercy", 14, "A cool hat")
    user.add_new_item("Prussian Pickelhaube", 11, "A cool hat").active  =true
    user.add_new_item("Troublemaker's tossle cap", 8, "A cool hat").active  =true
    user.add_new_item("Hero's Hachimaki", 12, "A cool hat")
    user.add_new_item("Sergeant's drill hat", 10, "A cool hat").active  =true
    user.add_new_item("Handyman's Handle", 18, "A cool hat").active  =true

    user2 = Models::User.named("ese", "pw ese")
    user2.add_new_item("Nyan Cat", 80, "The ultimate internet cat").active = true
    user2.add_new_item("Pink Unicorn", 100, "Yay, unicorn! PINK unicorn!")
    user2.add_new_item("Overly attached girlfriend", 0, "Take it, it's for free!!!").active=true
    user2.add_new_item("Charizard", 75, "You totally need this!").active=true

    user3 = Models::User.named("Darth Vader", "pw Darth Vader")
    user3.add_new_item("Death star", 10000, "Big ass space ship").active=true
    user3.add_new_item("Storm trooper", 25, "Do you already own one?")
    user3.add_new_item("Force", 10, "Super cool").active = true

    user4 = Models::User.named("Steve", "pw Steve")
    user4.add_new_item("Dirt", 1, "Minecraft :D").active = true
    user4.add_new_item("Diamond Pickaxe", 75, "Minecraft :D").active = true
    user4.add_new_item("Stone", 5, "Minecraft :D").active = true
    user4.add_new_item("Redstone", 10, "Minecraft :D").active = true
    user4.add_new_item("Log", 2, "Minecraft :D").active = true
    user4.add_new_item("Sand", 1, "Minecraft :D").active = true
    user4.add_new_item("Workbench", 3, "Minecraft :D").active = true
  end


end

App.run!