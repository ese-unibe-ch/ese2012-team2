require 'haml'
require './models/item'
require './models/user'
require 'digest/md5'

class Main  < Sinatra::Application
  #SH Get the user by session
  before do
     @active_user = Models::User.by_name(session[:name])
  end

  #SH Redirect to the main page
  get "/" do
    redirect "/index"
  end

  #SH Check if logged in and show a list of all active items if true
  get "/index" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::Item.all, :error => nil }
  end

  #SH Shows all items of a user
  get "/user/:name" do
    redirect '/login' unless session[:name]
    user = Models::User.by_name(params[:name])
    haml :user, :locals =>{:user => user}
  end

  #SH Buys an item. If an error occurs, redirect to the buy error page
  post "/buy/:item" do
    redirect '/login' unless session[:name]
    item = Models::Item.by_id params[:item].to_i

    if @active_user.buy(item) == "credit error"
      redirect "/index/credit"
    end
    redirect '/index'
  end

  #SH Shows errors caused by buy on the main page
  get "/index/:error" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::Item.all, :error => params[:error] }
  end

  #SH Triggers status of an item
  post "/change/:item" do
    redirect '/login' unless session[:name]
    item = Models::Item.by_id(params[:item].to_i)

    #TODO PS check if user is owner of the item!
    if params[:action] == "Activate"
      item.active = true
    end

    if params[:action] == "Deactivate"
      item.active = false
    end

    redirect back
  end

  #SH Tries to add an item. Redirect to the additem message page.
  post "/additem" do
    redirect '/login' unless session[:name]

    name = params[:name]
    price = params[:price]

    if price.to_i < 0
      redirect "/additem/negative_price"
    end

    filename = nil

    unless params[:image].nil?
    #PS process and save image
      filename = Digest::MD5.hexdigest(params[:image][:filename] + Time.now.to_s)  + "." + params[:image][:filename].split(".").last()

      #PS TODO check if filename already exists and generate new filename
      #PS TODO check if file is an image
      File.open(options.public_folder + '/images/items/' + filename, "w") do |file|
        file.write(params[:image][:tempfile].read)
        #PS TODO resize image
      end
    end

    @active_user.add_new_item(name, price.to_i, filename)
    redirect "/additem/success"
  end

  #SH Shows a form to add items
  get "/additem" do
    redirect '/login' unless session[:name]
    haml :add_new_item, :locals=>{:message => nil}
  end




  #SH Shows either an error or an success message above the add item form
  get "/additem/:message" do
    haml :add_new_item, :locals=>{:message => params[:message]}
  end

  #SH Shows the register form
  get "/register" do
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    Models::User.named(params[:username])
    redirect "/login"
  end

  #SH Shows a list of all user and their credits
  get "/user" do
    redirect '/login' unless session[:name]
    haml :users, :locals => {:users => Models::User.all}
  end
end