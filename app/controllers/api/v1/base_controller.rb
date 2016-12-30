class Api::V1::BaseController < RocketPants::Base
  version 1

  before_filter :authenticate_user_from_token
  before_filter :require_authentication!

  def current_user
    @current_user
  end

  def require_authentication!
    error! :unauthenticated if current_user.nil?
  end

  def authenticate_user_from_token
    print("arrived")
    user = authenticate_with_http_token do |token, options|
      user_id = options[:user_id]
      user = user_id && User.find_by_id(user_id)

      if user && Devise.secure_compare(user.authentication_token, token)
        user
      else
        nil
      end
    end

    @current_user = user
  end
end