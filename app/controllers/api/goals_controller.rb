module Api
  #TODO Replace implied required user_id parameter with authenticated user
  class GoalsController < ApplicationController
    include S3Bucket
    before_action :set_goal, except: [:create, :index]

    # GET /goals
    def index
      @goals =  @user ? Goal.where(user: @user) : Goal.all
      @goals = Goal.all
      json_response(@goals)
    end

    # POST /goals
    def create
      @goal = Goal.create!(goal_params)
      json_response(@goal, :created)
    end

    # GET /goals/:id
    def show
      json_response(@goal)
    end

    # PUT /goals/:id
    def update
      @goal.update(goal_params)
      json_response(@goal)
    end

    # DELETE /goals/:id
    def destroy
      @goal.destroy
      head :no_content
    end

    # Delete /goals/:id/purge
    def purge
      @goal.interactions.destroy_all
      head :no_content
    end

    def presigned_url
      filename = params['filename']
      return bad_request('Filename not provided!') unless filename
      key = s3_bucket_path('goals', @goal.id, @goal.title ,filename)
      json_response(s3_presigned_url(key))
    end

    private

    def goal_params
      # whitelist params
      params.permit(:title,  :description, :instructions, :image_url, :user_id)
    end

    def set_goal
      set_user
      @goal = Goal.includes(:interactions, :contents).find(params[:id])
      @goal = @goal.user_id == @user.id ? @goal : nil
    end

    # TODO use auth to determine current user.
    # Only admin can specify a different user.
    def set_user
      user_id = params['user_id']
      @user = user_id ? User.find(user_id) : User.find(1)
    end
  end
end
