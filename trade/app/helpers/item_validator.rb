require_relative '../models/item'

class ItemValidator

  #SH Removing heading zeros because these would make the int oct
  def self.delete_leading_zeros(price)
    while price.start_with?("0") and price.length > 1
     price.slice!(0)
    end
    return price
  end

  def self.add_item params, active_user
    name = params[:name]
    price = params[:price]
    description = params[:description]
    endtime = params[:endtime]

    price = ItemValidator.delete_leading_zeros(price)

    if (active_user.working_for.nil?)
      user = active_user
    else
      user = active_user.working_for
    end
    item = Models::Item.new(name, price, user, description)
    item.end_time = endtime
    image_name = ImageHelper.save params[:image], "#{settings.public_folder}/images/items"
    item.image = image_name
  end
end