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
require_relative 'models/trackable'
require_relative 'models/activity'
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
require_relative 'controllers/payment_controller'

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
  use PaymentController
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
        it = Models::Item.new(item["name"], item["price"], new_user, item["description"], item["state"].to_sym)
        unless item["tags"].nil?
          item["tags"].each do |tag|
            it.add_tag(Models::Tag.get_tag(tag))
          end
        end
      end
    end
  end

  configure :development do

    self.load_test_data

    overlay =  Models::DataOverlay.instance
    Models::Organization.new("Test", "Bla", overlay.user_by_name("ese"), nil).add_member(overlay.user_by_name("Steve"))


    scheduler = Rufus::Scheduler.start_new

    scheduler.every '10s' do
      puts "running task"
      for item in overlay.all_items
        if item.over?
          item.end_offer
        end
      end
      for user in overlay.all_users
        if user.expired?
          UserDataHelper.delete_user user
        end
      end
    end
  end
end

App.run!