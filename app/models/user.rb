class User < ActiveRecord::Base
  has_many :accounts,:dependent => :destroy
  # devise :openid_authenticatable

  def check_account
    user = User.find(:all)
    user.account.where(:identifier_url => openid.display_identifier).first
  end
end
