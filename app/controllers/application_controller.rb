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
      token =  decoded_auth_token
      @current_user = User.find(decoded_auth_token["user_id"]) if token.key?("user_id")
    end
    @current_user
  end

  def encode_auth_token(user_id)
    JWT.encode({user_id: user_id}, SECRET)
  end

  def decoded_auth_token
    token ||= http_auth_header
    token ? JWT.decode(token, SECRET)[0] : {}
  end

  def http_auth_header
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      if token.split('.').length == 3
        return token
      end
    end
    nil
  end
end

