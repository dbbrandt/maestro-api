module Api
  class GoalsController < ApplicationController
    include S3Bucket
    before_action :set_goal, except: [:create, :index]

    # GET /goals
    def index
      @goals =  @current_user.admin ?  Goal.all : Goal.where(user: @current_user)
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
      if @current_user.admin
        params.permit(:title,  :description, :instructions, :image_url, :user_id)
      else
        goal_params = params.permit(:title,  :description, :instructions, :image_url)
        goal_params[:user_id] = @current_user.id
        goal_params
      end
    end

    def set_goal
      @goal = Goal.includes(:interactions, :contents).find(params[:id])
      @goal = nil unless @current_user.admin || @goal.user_id == @current_user.id
    end
  end
end
