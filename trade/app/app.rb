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
require_relative 'models/trader'
require_relative 'controllers/main'
require_relative 'controllers/authentication'
require_relative 'controllers/item_controller'
require_relative 'controllers/change_password'
require_relative 'controllers/reset_password'
require_relative 'controllers/organization_controller'
require_relative 'controllers/base_controller'
require_relative 'controllers/base_secure_controller'
require_relative 'controllers/comment_controller'
require_relative 'controllers/last_resort_controller'
require_relative 'controllers/tracking_controller'

class App < Sinatra::Base

  enable :sessions
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public") }
  set :safe_passwords, false

  use Authentication
  use ResetPassword
  use Main
  use ItemController
  use ChangePassword
  use OrganizationController
  use ResetPassword
  use CommentController
  use TrackingController
  use LastResortController

  enable :sessions
  set :show_exceptions, false
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new { File.join(root, "public") }

  def self.load_test_data
    overlay = Models::DataOverlay.instance

    document = IO.read(File.dirname(__FILE__) + "/test_data.json")
    data = JSON.parse(document)

    data.each do |user|
      new_user = Models::User.new(user["name"], user["displayname"], user["pw"], user["email"], user["interests"])
      user["items"].each do |item|
        Models::Item.new(item["name"], item["price"], new_user, item["description"], item["state"].to_sym)
      end
    end
  end

  configure :development do
    self.load_test_data

    overlay =  Models::DataOverlay.instance
    Models::Organization.new("Test", "Bla", overlay.user_by_name("ese"), nil).add_member(overlay.user_by_name("Steve"))

  end
end

App.run!