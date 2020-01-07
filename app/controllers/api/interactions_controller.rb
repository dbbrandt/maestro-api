module Api
  class InteractionsController < ApplicationController
    before_action :set_goal

    MMAPIPY_URL="http://www.memorymaestro.com/mm-api-py"

    # GET /goals/:goal_id/interactions
    def index
      type = params['type'] == 'mc' ? :multiple_choice : :short_answer
      result = @goal.interactions
      if params['deep']
        result = result.send(type).includes(:contents).map {|i| deep_response(i)}
        if params['deep'] == 'game'
          size = params['size'] ? (params['size'].to_i - 1)  : 49
          result = result.shuffle[0..size]
        end
      end
      json_response(result)
    end

    # GET /goals/:goal_id/interactions/:id
    def show
      json_response(params["deep"] ? deep_response(@interaction) : @interaction )
    end

    # POST /goals/:goal_id/interactions
    def create
      @interaction = @goal.interactions.create!(interaction_params)
      save_contents if params['prompt']
      json_response(params["prompt"] ? deep_response(@interaction) : @interaction, :ok)
    end

    # PUT /goals/:goal_id/interactions/:id
    def update
      @interaction.update(interaction_params)
      save_contents if params['deep']
      json_response(params["deep"] ? deep_response(@interaction) : @interaction, :ok)
    end

    # DELETE /goals/:goal_id/interactions/:id
    def destroy
      @interaction.destroy
      head :no_content
    end

    # GET /goals/:goals_id/interactions/:id?answer=
    def check_answer
      answer = params['answer']
      correct_answer = @interaction.correct_answer
      correct, score = @interaction.check_answer(answer)

      params = "?answer=#{answer}&correct=#{correct_answer}"
      predicted = correct_answer
      if !answer.empty?
        response = HTTParty.get(MMAPIPY_URL+params)
        if response.code == 200
          logger.info("HTTP mm-api-py result: #{response.body}")
          results = JSON.parse(response.body)
          predicted = results['prediction']
          # Use the mm-api-py value unless it's overriden locally by a high score
          # We still want to see what the api returns
          correct = results['correct'] unless correct && @interaction.score_override?(score)
        else
          logger.error "check_answer: Https request faild with #{response.code} - #{response.body}"
        end
      end
      json_response({
         "correct": correct,
         "score": score,
         "predicted": predicted
      })
    end

    def submit_review
      response = save_response(params['answer'], params['score'], params['correct'], params['review'])
      json_response({
          "round": @round.id,
          "response": response.id
      })
    end

    private

    def interaction_params
      params.permit(:title, :answer_type, :prompt, :criterion)
    end

    def set_goal
      # require the goal context for all interaction requests
      return unless params[:goal_id]
      @goal = Goal.preload(:interactions).find(params[:goal_id])
      @interaction = Interaction.preload(:contents).find(params[:id]) if params[:id]
      set_round if params['round']
    end

    def set_round
      user = Fae::User.first
      if params['round']
        round_id = params['round'].to_i
        @round = Round.where(id: round_id).first
        @round = Round.create(goal: @goal, fae_user_id: user.id) unless @round
      end
    end

    def save_response(answer, score, is_correct, review_is_correct)
      RoundResponse.create(round: @round, interaction: @interaction, answer: answer, score: score,
                                      is_correct: is_correct, review_is_correct: review_is_correct)
    end

    def deep_response(interaction)
       i = interaction
       p = interaction.prompt
      {
        "id": i.id,
        "title": i.title,
        "answer_type": i.answer_type,
        "created_at": i.created_at,
        "updated_at": i.updated_at,
        "prompt": {
            "id": p&.id,
            "title": p&.title,
            "copy": p&.copy,
            "stimulus_url": i.stimulus_url
        },
        "criterion": criterion_response(interaction)
      }
    end

    def criterion_response(interaction)
      resp = interaction.criterion.map do |c|
        {
            "id": c.id,
            "title": c.title,
            "description": c.description,
            "copy": c.copy,
            "descriptor": c.descriptor,
            "score": c.score
        }
      end
      resp
    end

    def save_contents
      create_or_update_prompt

      # Perform appropriate CRUD action based on params for criterion
      criterion = params['criterion']
      ids = @interaction.criterion.map {|criteria| criteria.id }
      update_ids = criterion.map {|criteria| criteria['id']}.compact
      delete_ids = ids - update_ids
      delete_ids.each {|id| delete_criterion(id)}
      criterion.each_with_index do |criteria|
          id = criteria['id']
          if delete_ids.include?(id)
            delete_criterion(id)
          elsif update_ids.include?(id)
            update_criterion(id, criteria)
          else
            create_criterion(criteria)
          end
      end
    end

    def create_or_update_prompt
      prompt = @interaction.prompt
      values = params['prompt']
      title = values['title'].blank? ? params['title'] : values['title']
      copy = values['copy']
      #TODO support saving stimulus_url
      if prompt
        prompt.title = title
        prompt.copy = copy
        prompt.save
      else
        @interaction.contents.create!( content_type: Content::PROMPT, title: title, copy: copy)
      end
    end

    def delete_criterion(id)
      Content.delete(id)
    end

    def update_criterion(id, values)
        criteria = Content.find(id)
        criteria.update!(criteria_values(values))
    end

    def create_criterion(values)
        @interaction.criterion.create!(criteria_values(values))
    end

    def criteria_values(criteria)
      {
          title: criteria['title'].blank? ? params['title'] : criteria['title'],
          content_type: Content::CRITERION,
          copy: criteria['copy'].blank? ? criteria['descriptor'] : criteria['copy'],
          description: criteria['description'],
          descriptor: criteria['descriptor'],
          score: criteria['score']
      }
    end
  end
end
