require_relative '../models/user'

class Authentication < Sinatra::Application

  before do
    @data = Models::DataOverlay.instance
  end

  #SH The normal login page
  get "/login" do
    haml :login, :locals =>{:error => nil}
  end

  #SH The login page when an error occurred
  get "/login/:error" do
    haml :login , :locals =>{:error => params[:error]}
  end

  #SH Checks whether login was successful and if so, log the user in.
  #SH Otherwise, redirect to the error page
  post "/login" do
    name = params[:username]
    password = params[:password]
    user = @data.user_by_name name
    if user.nil? || !user.authenticated?(password)
      redirect '/login/wrong'
    else
      session[:name] = name
      redirect '/'
    end

  end

  #SH Logs the user out
  get "/logout" do
    session[:name] = nil
    redirect '/login'
  end


  #SH Shows the register form
  get "/register" do
    haml :register
  end

  #SH Adds an user an redirect to the login page
  post "/register" do
    if Models::User.passwd_valid?(params[:passwd])
      if params[:passwd]==params[:passwd_repetition]
        unless @data.user_exists?(params[:username])
          @data.new_user(params[:username], params[:passwd])
          redirect "/login"
        else
          redirect "/register/user_exists"
        end
      else
        redirect "/register/wrong_repetition"
      end
    else
      redirect "/register/password_invalid"
    end
  end

  #AS sending a message about success to the register view
  get "/register/:message" do
    haml :register, :locals=>{:message => params[:message]}
  end

end