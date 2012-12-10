require_relative 'base_secure_controller'

class PaymentController < BaseSecureController
  get "/insert_coins" do
    haml :insert_coins
  end

  post "/insert_coins" do
    information = Hash.new
    information[:CVC] = params[:CVC].to_i
    information[:valid_thru] = params[:valid_thru][3,params[:valid_thru].length]
    information[:card_number] = params[:card_number]
    puts information
    payRef = Models::PaymentServer.instance().reference(information)
    if(payRef.status == :inexistent)
      flash[:error] = ("there has been a problem with your payment information. Please check your data")
      redirect back
    end
    amount = params[:amount].to_i
    id = nil
    begin
      id = payRef.withdraw(amount)
    rescue Exception => e
      flash[:error] = ("there has been a problem with the transaction: check if you have enough money and your credit card is not blocked")
      redirect back
    else
      @active_user.credits += 10 * amount
      haml :successful_payment, :locals => {:id => id}
    end
  end
end