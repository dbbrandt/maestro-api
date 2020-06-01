class Api::RoundsController < ApplicationController
  before_action :set_goal

  def index
    if @current_user.admin || @goal.user_id == @current_user.id
      @rounds = Round.preload(:round_responses).where(goal_id: @goal)
      result = @rounds.map {|g| rounds_list(g, !!params['deep'])}
      json_response(result)
    else
      forbidden_request('Invalid user request!')
    end

  end

  def show
    json_response(rounds_list(@round, !!params['deep']))
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
    return unless params['id']
    @round = Round.where(id: params['id']).first
  end


  def rounds_list(round, deep = false)
    total = round.round_responses.count
    correct = round.round_responses.select {|r| r.review_is_correct }.count
    {
        id: round.id,
        goal_id: round.goal_id,
        user_id: round.user_id,
        title: @goal.title,
        total: total,
        correct: correct,
        score: total > 0 ? (100 * correct / total).round : 0,
        round_responses: deep ? deep_responses(round) : [],
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

