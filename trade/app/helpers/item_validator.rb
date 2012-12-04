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
    end_time = self.parse_date_time(params[:date], params[:time])

    #PS TODO tags ist ein array mit tag namen... ab hier einfach einbauen
    tags = params[:tags]
    for tag in tags do
     puts "tags: #{tag}"
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

  def self.parse_date_time(date,time)
    unless date == ""
      if time == ""
        raise TradeException, "please select a time"
      end
      time_string = "#{date}T#{time} +0100"
       begin
         end_time = DateTime.strptime(time_string, "%d-%m-%YT%H:%M %Z")
         if end_time < DateTime.now
           raise TradeException, "End time must be in the future"
         end
         return end_time
       rescue
         raise TradeException, "DateTime format invalid"
       end
    end
  end
end