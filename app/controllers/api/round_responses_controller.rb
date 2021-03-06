class Api::RoundResponsesController < ApplicationController
  before_action :set_goal

  def index
    result = params['deep'] ? deep_responses : @round.round_responses.sort_by(&:id)
    json_response(result)
  end

  def show
    json_response(params['deep'] ? deep_response(@response) : @response)
  end

  private

  def set_goal
    # require the goal context for all round requests
    return unless params['goal_id']
    # TODO modify when user model and security incorporate
    @goal = Goal.includes(:interactions, :contents).find(params[:goal_id])
    set_round if @goal
  end

  def set_round
    set_user
    return unless params['round_id']
    @round = Round.includes(:round_responses).where(id: params['round_id'], user_id: @user).first
    set_round_response if @round
  end

  def set_round_response
    @response = @round.round_responses.find { |r| r.id == params[:id].to_i}
  end

  # TODO use auth to determine current user.
  # Only admin can specify a different user.
  def set_user
    user_id = params['user_id']
    @user = user_id ? User.find(user_id) : User.find(1)
  end

  def deep_responses
    @round.round_responses.map {|r| deep_response(r)}.sort_by {|r| r["id"]}
  end

  def deep_response(response)
    response.attributes.merge(deep_interaction(response.interaction))
  end

  def deep_interaction(interaction)
    { interaction: interaction.attributes.merge(deep_contents(interaction)) }
  end

  def deep_contents(interaction)
    contents = interaction.contents.map {|c| c.attributes }
    if interaction.criterion.length == 1
      {
          contents: contents,
          prompt: interaction.prompt,
          criterion: interaction.criterion[0]
      }
    else
      { contents: contents }
    end
  end
end

