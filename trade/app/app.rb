require 'rubygems'
require 'bundler'
require 'json/pure'
# This actually requires the bundled gems
Bundler.require

require_relative 'event/base_event'
require_relative 'event/item_update_event'
require_relative 'models/user'
require_relative 'models/item'
require_relative 'models/comment'
require_relative 'models/data_overlay'
require_relative 'controllers/main'
require_relative 'controllers/authentication'
require_relative 'controllers/item_controller'
require_relative 'controllers/change_password'
require_relative 'controllers/reset_password'
require_relative 'controllers/base_controller'
require_relative 'controllers/base_secure_controller'
require_relative 'controllers/comment_controller'

class App < Sinatra::Base

  use Authentication
  use ResetPassword
  use Main
  use ItemController
  use ChangePassword
  use ResetPassword
  use CommentController

  enable :sessions
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public") }

  def self.load_test_data
    overlay = Models::DataOverlay.instance

    document = IO.read(File.dirname(__FILE__) + "/test_data.json")
    data = JSON.parse(document)

    data.each do |user|
      new_user = Models::User.named(user["name"], user["displayname"], user["pw"], user["email"], user["interests"])
      overlay.add_user new_user
      user["items"].each do |item|
        overlay.new_item(item["name"], item["price"], item["description"], new_user, item["state"].to_sym)
      end
    end
  end

  configure :development do
    self.load_test_data
  end


end

App.run!