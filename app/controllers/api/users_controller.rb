module Api
  class UsersController < ApplicationController
    include S3Bucket
    before_action :set_user, except: [:create, :index]

    # GET /users
    def index
      @users = User.all
      json_response(@users)
    end

    # POST /users
    def create
      @user = User.create!(user_params)
      json_response(@user, :created)
    end

    # GET /users/:id
    def show
      json_response(@user)
    end

    # PUT /users/:id
    def update
      @user.update(user_params)
      json_response(@user)
    end

    # DELETE /users/:id
    def destroy
      @user.destroy
      head :no_content
    end

    # Delete /users/:id/purge
    def purge
      @user.goals.destroy_all
      head :no_content
    end

    def presigned_url
      filename = params['filename']
      bad_request('Filename not provided!') unless filename
      key = s3_bucket_path('users', @user.id, @user.name, filename)
      json_response(s3_presigned_url(key))
    end

    private

    def user_params
      # whitelist params
      params.permit(:email, :password, :name,  :avatar_url, )
    end

    def set_user
      @user = User.find(params[:id])
    end
  end
end
