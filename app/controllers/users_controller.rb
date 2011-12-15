# To change this template, choose Tools | Templates
# and open the template in the editor.

class UsersController < ApplicationController

  skip_before_filter :ensure_signed_in

  def login
    if session[:user_id]
      @accounts = Account.where(:user_id => session[:user_id])
    end
  end


  def new
    # logger.debug  users_url
    response.headers['WWW-Authenticate'] = Rack::OpenID.build_header(
      :identifier => "https://www.google.com/accounts/o8/id",
      :required => ["http://axschema.org/contact/email",
                    "http://axschema.org/namePerson/first",
                    "http://axschema.org/namePerson/last",],
      :return_to => user_url,
      :method => 'POST')
    # logger.debug response.headers['WWW-Authenticate']
    head 401
  end

  #
  # Create new user
  #
  def create
    # logger.debug params
    if openid = request.env[Rack::OpenID::RESPONSE]
      # logger.debug openid.inspect
      case openid.status
        when :success
          ax = OpenID::AX::FetchResponse.from_success_response(openid)
          @account = Account.joins(:user).where(:google_identifier => openid.display_identifier).first
          # logger.debug @account.inspect
          # exit
          if @account.nil?
            @user ||= User.create!(
              # :email => ax.get_single("http://axschema.org/contact/email"),
              :firstname => ax.get_single("http://axschema.org/namePerson/first"),
              :lastname => ax.get_single("http://axschema.org/namePerson/last")
            )
            if @user
              @account = @user.accounts.create({
                :email => ax.get_single("http://axschema.org/contact/email"),
                :google_identifier => openid.display_identifier
              })
            end
          end
          session[:user] = @account
          session[:user_id] = @account.user_id
          
          # if @user.firstname.blank?
          #   redirect_to user_profile_path(@user)
          # else
            redirect_to(session[:redirect_to]|| root_path)
          # end
        when :failure
          render :action => 'problem'
        end
    else
      redirect_to "users/dashboard"
    end
  end


  def dashboard
    
  end
  #
  #logout user
  #
  def logout
    session[:user_id] = nil
    redirect_to root_path
  end

end