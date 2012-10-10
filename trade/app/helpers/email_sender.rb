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
      :from => 'trade-corp-noreply@web.de',
      :subject => 'Password reset'
  }

  def self.send_new_password(user, pw)
     Pony.mail ({
       #:to => user.mail,
       :to => 'kenneth.radunz@web.de',
       :body => "Dear #{user.name} \n Your password was reset.
Your new password is #{pw}.
Please do not reply."
     })
  end
end