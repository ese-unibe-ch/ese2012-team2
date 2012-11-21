require_relative '../models/item'

class ItemValidator

  #SH Removing heading zeros because these would make the int oct
  def self.delete_leading_zeros(price)
    while price.start_with?("0") and price.length > 1
     price.slice!(0)
    end
    return price
  end

  def self.add_item params, active_user, as_request
    name = params[:name]
    price = params[:price]
    description = params[:description]
    if params[:endtime] == ""
      end_time = nil
    else
      begin
        end_time = DateTime.strptime(params[:endtime], "%d-%m-%Y")
        if end_time < DateTime.now
          raise TradeException, "End time must be in the future."
        end
      rescue ArgumentError
        raise TradeException, "Invalid date format for end time"
      end
    end

    price = ItemValidator.delete_leading_zeros(price)

    if (active_user.working_for.nil?)
      user = active_user
    else
      user = active_user.working_for
    end
    item = Models::Item.new(name, price, user, description, :inactive, nil, as_request, end_time)
    image_name = ImageHelper.save params[:image], "#{settings.public_folder}/images/items"
    item.image = image_name
  end
end