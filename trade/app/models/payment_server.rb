require 'singleton'

module Models
  class PaymentServer
    include Singleton

    @references = nil

    def initialize()
       @references = Array.new
    end

    def add(reference)
      @references.push reference
    end

    def reference(data)
      ref = @references.detect {|ref|
        puts "#{data} == #{ref.information} => #{data == ref.information}"
        data == ref.information
      }
      ref = PaymentReference.new(:inexistent, 0, Hash.new) if ref == nil
      ref
    end
  end
end