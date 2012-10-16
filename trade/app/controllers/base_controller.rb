class BaseController < Sinatra::Application

  attr_accessor :message, :active_user

  before do
    #redirect to login
    redirect '/login' unless session[:name]
    #set current user
    @data = Models::DataOverlay.instance
    @active_user = @data.user_by_name(session[:name])
    @title = ""
  end

  def add_message(text, type=:info)
    self.message = {:type => type, :text => text}
  end
end