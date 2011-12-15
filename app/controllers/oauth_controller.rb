
require "google/api_client"

class OauthController < ApplicationController

  before_filter :doBefore
  skip_before_filter :ensure_signed_in

  def doBefore
    @client = Google::APIClient.new
    @client.authorization.client_id = '245083617981.apps.googleusercontent.com'
    @client.authorization.client_secret = 'pYelZCRjSa+iMezYENVScXFk'
    @client.authorization.scope = 'https://www.googleapis.com/auth/buzz'
    @client.authorization.redirect_uri = 'http://localhost:3000/oauth/callback'
    @client.authorization.code = params[:code] if params[:code]
    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end
    @buzz = @client.discovered_api('buzz')
    unless @client.authorization.access_token || request.path_info =~ /^\/oauth2/
      redirect_to('/oauth/authorize')
    end
  end

  def callback
    @client.authorization.fetch_access_token!
    # Persist the token here
    session[:token_id] = @client.authorization.id
    redirect to('/')
  end

  def authorize
    logger.debug @client.authorization.authorization_uri.to_s
    redirect @client.authorization.authorization_uri.to_s, 303
  end

  def index
    response = @client.execute(
      @buzz.activities.list,
      'userId' => '@me', 'scope' => '@consumption', 'alt'=> 'json'
    )
    status, headers, body = response
    [status, {'Content-Type' => 'application/json'}, body]
  end
end