class EmailSender

  Pony.options= {
      :via => :smtp,
      :via_options => {
          :address => 'smtp.web.de',
          :port => '587',
          :user_name => 'trade-corp-noreply', #Todo create an email account
          :password => 'tradecorp',
          :authentication => :plain
      },
      :from => 'trade-corp-noreply@web.de'
  }

  def self.send_item_bought(item)
    seller = item.prev_owners.last
    buyer = item.owner
    Thread.new {
       Pony.mail({
         :to => seller.email,
         :subject => 'Password reset',
         :body => "Dear #{seller.display_name}
Your item #{item.name} has been bought by #{buyer.display_name}
Please do not reply."
       })
     }
  end

  def self.send_new_password(user, pw)
    Thread.new {
      Pony.mail({
                    :to => user.email,
                    :subject => 'Password reset',
                    :body => "Dear #{user.name}
Your password was reset.
Your new password is #{pw}.
Please do not reply."
                })
    }
  end

  def self.send_item_found(user, search_request, item)
    Thread.new {
      Pony.mail({
        :to => user.email,
        :subject => "Your Search matched an item",
        :body => "Dear #{user.name}
One of your subscribed Searches matched with an item:
Keywords: #{search_request.keywords}
Item: #{item.name}
Price: #{item.price}
Description: #{item.description}
Owner: #{item.owner}"
                })
      }
  end
  def self.send_auction(user, item)
    Thread.new {
      Pony.mail({
                    :to => user.email,
                    :subject => "Auction Update",
                    :body => "Dear #{user.name}
You dont't lead the auction for #{item.name} anymore.
Go back and raise your bid or resign

"
                })
    }
  end
end