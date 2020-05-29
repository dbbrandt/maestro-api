module Api
  class AuthController < ApplicationController
    before_action :set_user

    def authorize
      token = @user ? encode_auth_token(@user.id) : nil
      status = @user ?  :ok : :forbidden
      response = @user ? {user: @user, auth_token: token} : nil
      json_response(response, status)
    end

    private
    def set_user
      # keep the user from the token if provided (bypass a new authorization)
      @user ||= @current_user
      # Try finding user by email then id.
      @user ||= User.find_by_email(params[:email]) unless @user
      @user ||= User.find_by_id(params[:id])
    end
  end
end
