class BaseController < Sinatra::Application
  attr_accessor :message, :title

  before do
    params.each do |key, param|
      if param.is_a? String
        params[key] = Sanitize.clean(param)
      end
    end
  end

  def add_message(text, type=:info)
    self.message = {:type => type, :text => text}
  end
end