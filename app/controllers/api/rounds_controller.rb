class Api::RoundsController < ApplicationController
  before_action :set_goal
  def index
    @rounds = Round.where(user_id: @user)
    result = @goals.map {|g| goal_response(g)}
    json_response(result)

  end

  def show
    json_response(@round)
  end

  def set_goal
    # require the goal context for all round requests
    return unless params['goal']
    # TODO modify when user model and security incorporate
    @user = User.get(1)
    @goal = Goal.preload(:interactions, :contents).find(params[:id])
    set_round if @goal
  end

  def set_round
    return unless params['round']
    @round = Round.where(id: round_id).first
  end

end

