require 'haml'
require './models/user'
class Item < Sinatra::Application
  #SH Get the user by session
  before do
    @active_user = Models::User.by_name(session[:name])
  end

  #SH Triggers status of an item
  post "/change/:item" do
    redirect '/login' unless session[:name]
    item = Models::Item.by_id(params[:item].to_i)

    if params[:action] == "Activate" && item.owner == @active_user
      item.active = true
    end

    if params[:action] == "Deactivate" && item.owner == @active_user
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

    @active_user.add_new_item(name, price.to_i)
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

end