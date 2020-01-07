module Api
  class GoalsController < ApplicationController
    before_action :set_goal, only: [:show, :update, :destroy, :purge]

    # GET /goals
    def index
      @goals = Goal.all
      result = @goals.map {|g| goal_response(g)}
      json_response(result)
    end

    # POST /goals
    def create
      @goal = Goal.create!(goal_params)
      json_response(goal_response(@goal), :created)
    end

    # GET /goals/:id
    def show
      json_response(goal_response(@goal))
    end

    # PUT /goals/:id
    def update
      @goal.update(goal_params)
      json_response(goal_response(@goal))
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


    private

    def goal_params
      # whitelist params
      params.permit(:title,  :description, :instructions)
    end

    def set_goal
      @goal = Goal.preload(:interactions, :contents).find(params[:id])
    end

    def goal_response(goal)
      {
          'id': goal.id,
          'title': goal.title,
          'image_url': goal.image_url,
          'created_at': goal.created_at,
          'updated_at': goal.updated_at,
      }
    end
  end
end
