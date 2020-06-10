class ApplicationController < ActionController::API
  SECRET = Rails.application.secrets.secret_key_base

  include ResponseHandler
  include ExceptionHandler
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      # Compare the tokens in a time-constant manner, to mitigate
      # timing attacks.
      return true if current_user
      ActiveSupport::SecurityUtils.secure_compare(token, SECRET)
    end
  end

  def current_user
    unless @current_user
      user_token =  decoded_auth_token
      # Use where rather than find in case an valid token for a deleted user is passed
      @current_user = User.where(id: user_token["user_id"]).first if user_token.key?("user_id")
    end
    @current_user
  end

  def encode_auth_token(user_id)
    JWT.encode({user_id: user_id}, SECRET)
  end

  def decoded_auth_token
    header = http_auth_header
    decoded_token = header ? JWT.decode(header, SECRET)[0] : {}
    decoded_token
  end

  def http_auth_header
    if request.headers['Authorization'].present?
      auth_token = request.headers['Authorization'].split(' ').last
      if auth_token.split('.').length == 3
        return auth_token
      end
    end
    nil
  end
end

