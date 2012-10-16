class BaseController < Sinatra::Application
  attr_accessor :message

  def add_message(text, type=:info)
    self.message = {:type => type, :text => text}
  end
end