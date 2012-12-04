module Models
  #this class is a reference to a payment model e.g. a credit card or a paypal account
  class PaymentReference
    attr_reader :status, :max_amount, :information

    def information
      @information.clone
    end

    def initialize(status, max_amount, information)
      @status = status
      @max_amount = max_amount
      @information = information
    end

    def withdraw(amount)
      raise "Withdrawal not possible" unless status == :active and max_amount >= amount
      @max_amount -= amount
      PaymentReference.random_id
    end

    def to_s
      "card number: #{self.information[:card_number]}, CVC: #{self.information[:CVC]}, valid thru: #{self.information[:valid_thru]}, status: #{self.status}, max_amount: #{self.max_amount}"
    end

    def self.random_id(size = 20)
      pool = ('0'..'9').to_a
      (1..size).collect{|a| pool[rand(pool.size)]}.join
    end
  end
end