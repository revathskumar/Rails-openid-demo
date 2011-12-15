# To change this template, choose Tools | Templates
# and open the template in the editor.

module AuthenticationHelper
  def signed_in?
    !session[:user_id].nil?
  end

	def current_user
    @current_user ||= User.find(session[:user_id]).first
    @loggedin_account ||= Account.find(session[:loggedin_account]).first
    logger.debug @loggedin_account.inspect
    logger.debug @current_user.inspect
  rescue
    session[:user_id] = nil
  end

  def ensure_signed_in
    if ENV['OFFLINE']
      session[:user_id] = 1
      return
    end

    unless signed_in? && User.find_by_id(session[:user_id])
      session[:user_id] = nil
      session[:redirect_to] = request.fullpath
      redirect_to(root_path)
    end
  end

	def login_required
		signed_in?
	end
end
