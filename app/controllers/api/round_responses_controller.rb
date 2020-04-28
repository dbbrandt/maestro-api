class Api::RoundResponsesController < ApplicationController
  before_action :set_goal

  def index
    result = @round.round_responses
    json_response(result)
  end

  def show
    json_response(@response)
  end

  private

  def set_goal
    # require the goal context for all round requests
    return unless params['goal_id']
    # TODO modify when user model and security incorporate
    @goal = Goal.preload(:interactions, :contents).find(params[:goal_id])
    set_round if @goal
  end

  def set_round
    set_user
    return unless params['round_id']
    @round = Round.where(id: params['round_id'], user_id: @user).first
    set_round_response
  end

  def set_round_response
    @response = @round.round_responses.find { |r| r.id == params[:id].to_i} if @round
  end

  # TODO use auth to determine current user.
  # Only admin can specify a different user.
  def set_user
    user_id = params['user_id']
    @user = user_id ? User.find(user_id) : User.find(1)
  end
end

