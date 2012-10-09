class ItemValidator

  def self.name_empty?(name)
    if name == ""
      return true
    end
    return false
  end

  #SH Removing heading zeros because these would make the int oct
  def self.delete_leading_zeros(price)
    while price.start_with?("0") and price.length > 1
     price.slice!(0)
    end
    return price
  end

  #SH Check if price is an int
  def self.price_is_integer?(price)
    unless price.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
      return false
    end
    return true
  end

  def self.price_negative?(price)
    if price.to_i < 0
      return true
    end
    return false
  end

end