class Api::RoundsController < ApplicationController
  before_action :set_goal

  def index
    @rounds = Round.preload(:round_responses).where(user_id: @user)
    result = @rounds.map {|g| round_response(g)}
    json_response(result)
  end

  def show
    json_response(@round)
  end

  private

  def set_goal
    # require the goal context for all round requests
    return unless params['goal']
    # TODO modify when user model and security incorporate
    user_id = params['user_id']
    @user = user_id ? User.get(user_id) : User.get(1)
    @goal = Goal.preload(:interactions, :contents).find(params[:id])
    set_round if @goal
  end

  def set_round
    return unless params['round']
    @round = Round.where(id: round_id).first
  end

  def round_response(round)
    {
        goal_id: round.goal_id

    }

  end
end

