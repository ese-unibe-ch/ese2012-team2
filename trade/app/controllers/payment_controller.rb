require_relative 'base_secure_controller'

class PaymentController < BaseSecureController
  get "/insert_coins" do
    haml :insert_coins
  end

  post "/insert_coins" do

  end
end