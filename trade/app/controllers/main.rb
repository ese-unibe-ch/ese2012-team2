require 'haml'
require './models/item'
require './models/user'

class Main  < Sinatra::Application
  before do
     @active_user = Models::User.by_name(session[:name])
  end

  get "/" do
    redirect "/index"
  end

  get "/index" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::Item.all, :error => nil }
  end

  get "/user/:name" do
    redirect '/login' unless session[:name]
    user = Models::User.by_name(params[:name])
    haml :user, :locals =>{:user => user}
  end

  post "/buy/:item" do
    redirect '/login' unless session[:name]
    item = Models::Item.by_name(params[:item])
    owner = item.owner

    if @active_user.buy(owner, item) == "credit error"
      redirect "/index/credit"
    end
    redirect '/index'
  end

  get "/index/:error" do
    redirect '/login' unless session[:name]
    haml :index, :locals => {:current_name => session[:name], :items => Models::Item.all, :error => params[:error] }
  end

  post "/:item" do
    redirect '/login' unless session[:name]
    item = Models::Item.by_name(params[:item])
    if params[:action] == "Activate"
      item.active = true
    end

    if params[:action] == "Deactivate"
      item.active = false
    end

    redirect back
  end

  get "/additem" do
    redirect '/login' unless session[:name]
     haml :add_item, :locals=>{:message => nil}
  end

  post "/additem" do
    redirect '/login' unless session[:name]
    name = params[:name]
    price = params[:price]

    if Integer(price) < 0
      redirect "/additem/negative_price"
    end

    if Models::Item.by_name(name) != nil
      redirect "/additem/invalid_item"
    end

    @active_user.add_item(name, price)
    redirect "/additem/success"
  end

  get "/additem/:message" do
    haml :add_item, :locals=>{:message => params[:message]}
  end

  get "/register" do
    haml :register
  end

  post "/register" do
    Models::User.named(params[:username])
    redirect "/login"
  end

  get "/user" do
    redirect '/login' unless session[:name]
    haml :users, :locals => {:users => Models::User.all}
  end
end