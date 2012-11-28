require 'rack-flash'
class BaseController < Sinatra::Application
  use Rack::Flash

  attr_accessor :message, :title

  before do
    params.each do |key, param|
      if param.is_a? String
        params[key] = Sanitize.clean(param)
      end
    end
  end
end