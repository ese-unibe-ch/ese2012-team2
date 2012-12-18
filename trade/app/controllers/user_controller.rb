class UserController < BaseSecureController
  #SH Shows a list of all user and their credits
  get "/user" do
    @title = "All users"
    haml :users, :locals => {:users => @data.all_users, :organizations => @data.all_organizations}
  end

  get "/user/:user/edit" do
    @title = "Edit user " + params[:user]
    haml :edit_user
  end

  post "/user/:user/edit" do
    @title = "Edit profile"
    begin
      UserDataHelper.edit_user(params, @active_user)
      flash.now[:success] = "Successfully saved user"
    rescue TradeException => e
      flash.now[:error] = e.message
    end
    haml :edit_user
  end

  post "/user/:user/suspend" do
    unless params[:suspend]
      flash[:error] = "You have to accept the checkbox before suspension"
      redirect back
    end
    unless UserDataHelper.can_suspend?(@active_user)
      flash[:error] = "Cant suspend account: check if you have active items, open auctions or membership in any organization"
      redirect back
    end
    @active_user.suspension_time = Time.now
    @active_user.state = :suspended
    flash[:success] = "Account successfully suspended"
    redirect "/logout"
  end

  get "/users_near_me" do
    @title = "Users near me"
    if params[:radius].nil?
      radius = 5
    else
      radius = params[:radius]
    end
    users_near_me = @active_user.users_near_me radius
    haml :user_near_me, :locals => {:users_near_me => users_near_me }
  end

  post '/user/edit/display_name/exists' do
    content_type :json
    #explicit true/false necessary for json serialization
    exists = false
    unless @active_user.display_name == params[:existing]
      if  @data.user_display_name_exists?(params[:existing])
        exists = true
      end
    end
    {:exists => exists }.to_json
  end

  #SH Shows all items of a user
  get "/user/:name" do

    @title = "User " + params[:name]
    user = @data.user_by_name(params[:name])

    if user.nil?
      flash[:error] = "User not found"
      redirect back
    end

    if self.is_active_user? user
      items = user.items
    else
      items = user.active_items
    end

    haml :user, :locals =>{:user => user, :items => items}
  end
end