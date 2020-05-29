module Api
  class UsersController < ApplicationController
    include S3Bucket
    before_action :check_permission, :set_user, except: [:create, :index]

    # GET /users
    def index
      @users = @current_user.admin ? User.all : User.where(id: @current_user.id)
      json_response(@users)
    end

    # POST /users
    def create
      if @current_user.nil? || @current_user.admin
        @user = User.create!(user_params)
        json_response(@user, :created)
      else
        forbidden_request('Invalid user request!')
      end
    end

    # GET /users/:id
    def show
      json_response(@user)
    end

    # PUT /users/:id
    def update
      @user.update(user_params) if @user
      json_response(@user)
    end

    # DELETE /users/:id
    def destroy
      if @current_user.admin
        @user.destroy
        head :no_content
      else
        forbidden_request('Invalid user request!') unless @current_user.admin
      end
    end

    # Delete /users/:id/purge
    def purge
      @user.goals.destroy_all
      head :no_content
    end

    def presigned_url
      filename = params['filename']
      return bad_request('Filename not provided!') unless filename
      key = s3_bucket_path('users', @user.id, @user.name, filename)
      json_response(s3_presigned_url(key))
    end

    private

    def user_params
      # whitelist params
      params.permit(:email, :password, :name,  :avatar_url )
    end

    # Only admin can specify a different user.
    def set_user
      @user = @current_user.admin ? User.find(params['id']) : @current_user
    end

    def check_permission
      unless @current_user.admin || @current_user.id.to_s == params[:id]
        forbidden_request('Invalid user request!')
      end
    end
  end
end
