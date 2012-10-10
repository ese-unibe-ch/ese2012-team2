require 'pony'

Pony.mail({
    #authentication
  :via => :smtp,
  :via_options => {
      :address => 'smtp.web.de',
      :port => '587',
      :user_name => '',
      :password => '', #I wont tell you
      :authentication => :plain
  },
  :to => 'kenneth.radunz@web.de',
  :from => 'justfsh@web.de',
  :subject => 'dafuq am i doing',
  :body => 'I give my best'
})