class Api::RoundsController < ApplicationController
  before_action :set_goal

  def index
    @rounds = Round.preload(:round_responses).where(goal_id: @goal, user_id: @user)
    result = @rounds.map {|g| round_response(g)}
    json_response(result)
  end

  def show
    json_response(@round)
  end

  private

  def set_goal
    # require the goal context for all round requests
    return unless params['goal_id']
    # TODO modify when user model and security incorporate
    user_id = params['user_id']
    @user = user_id ? User.find(user_id) : User.find(1)
    @goal = Goal.preload(:interactions, :contents).find(params[:goal_id])
    set_round if @goal
  end

  def set_round
    return unless params['round']
    @round = Round.where(id: round_id).first
  end

  def round_response(round)
    {
        id: round.id,
        goal_id: round.goal_id,
        user_id: @user.id,
        title: @goal.title,
        response_count: round.round_responses.count,
        created_at: round.created_at,
        updated_at: round.updated_at
    }
  end
end

