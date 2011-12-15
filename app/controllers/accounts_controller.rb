class AccountsController < ApplicationController

  before_filter :ensure_signed_in
  protect_from_forgery :except => :create

  def new
    response.headers['WWW-Authenticate'] = Rack::OpenID.build_header(
      :identifier => "https://www.google.com/accounts/o8/id",
      :required => ["http://axschema.org/contact/email"],
      :return_to => account_url,
      :pape => 0,
      :method => 'POST')
    # logger.debug response.headers['WWW-Authenticate']
    head 401
  end

  def create
    # logger.debug request.env[Rack::OpenID::RESPONSE]
    if openid = request.env[Rack::OpenID::RESPONSE]
      # logger.debug openid.inspect
      case openid.status
        when :success
          ax = OpenID::AX::FetchResponse.from_success_response(openid)
          @account = Account.where(:google_identifier => openid.display_identifier).first
          if @account.nil?
            @account = Account.create({
                :email => ax.get_single("http://axschema.org/contact/email"),
                :google_identifier => openid.display_identifier,
                :user_id => session[:user_id]
              })
          end

          redirect_to root_url
      end
    end
  end
end
