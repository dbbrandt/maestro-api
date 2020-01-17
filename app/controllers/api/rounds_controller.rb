class Api::RoundsController < ApplicationController
  before_action :set_goal

  def index
    @rounds = Round.preload(:round_responses).where(goal_id: @goal, user_id: @user)
    result = @rounds.map {|g| rounds_list(g, !!params['deep'])}
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
    @goal = Goal.preload(:interactions, :contents).find(params[:goal_id])
    set_round if @goal
    set_user
  end

  def set_round
    return unless params['round_id']
    @round = Round.where(id: round_id).first
  end

  # TODO use auth to determine current user.
  # Only admin can specify a different user.
  def set_user
    user_id = params['user_id']
    @user = user_id ? User.find(user_id) : User.find(1)
  end

  def rounds_list(round, deep = false)
    {
        id: round.id,
        goal_id: round.goal_id,
        user_id: @user.id,
        title: @goal.title,
        round_responses: deep ? deep_responses(round) : round.round_responses.count,
        created_at: round.created_at,
        updated_at: round.updated_at
    }
  end

  def deep_responses(round)
    round.round_responses.each do |response|
      response_list(response)
    end
  end

  def response_list(r)
    {
        id: r.id,
        answer: r.answer,
        score: r.score,
        is_correct: r.is_correct,
        review_is_correct: r.review_is_correct,
        descriptor: r.descriptor
    }
  end
end

