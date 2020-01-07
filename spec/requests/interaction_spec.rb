# spec/requests/interactions_spec.rb
require 'rails_helper'

RSpec.describe 'interactions API', type: :request do
  # initialize test data
  let!(:goal) { create(:goal) }
  let!(:goal_id) { goal.id }
  let!(:interactions) { create_list(:interaction, 10, goal: goal) }
  let!(:interaction) { interactions.first }
  let(:interaction_id) { interaction.id }
  let(:valid_attributes) { { title: 'Tom Hanks', answer_type: 'ShortAnswer' } }


  # Test reject requests that are not permitted for this resource
  context 'requests without a goal specified should fail' do
    describe 'GET /api/interactions' do
      it 'fails to find the route' do
        expect{ get "/api/interaction" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/interactions/:id' do
      it 'fails to find the route' do
        expect{ get "/api/interactions/#{interaction_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'PUT /api/interactions/:id' do
      it 'fails to find the route' do
        expect{ put"/api/interactions/#{interaction_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /api/interactions' do
      it 'fails to find the route' do
        expect{ post "/api/interactions" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'DELETE /api/interactions/:id' do
      it 'fails to find the route' do
        expect{ delete"/api/interactions/#{interaction_id}" }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # Test requests that scoped  to the goal
  context 'requests a goal''s interactions' do
    # Test suite for GET /goal/:goal_id/interactions
    describe 'GET /api/goals/:goal_id/interactions' do
      # make HTTP get request before each example
      before { get "/api/goals/#{goal_id}/interactions" }

      it 'returns interactions' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET /api/goals/:goal_id/interactions with params' do
      # make HTTP get request before each example
      before do
        create(:content, interaction: interaction)
        get "/api/goals/#{goal_id}/interactions?deep=true"
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns deep interactions' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json[0]["prompt"]).not_to be_nil
      end

      it 'returns multiple choice interactions' do
        expect(json.size).to eq(10)
      end

      it 'return short answer interactions' do
        interaction.update_attributes(answer_type: "MultipleChoice")
        get "/api/goals/#{goal_id}/interactions?deep=true&type=mc"
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end
    end

    # Test suite for GET /goal/:goal_id/interactions/:id
    describe 'GET /api/goals/:goal_id/interactions/:id' do
      context 'when the record exists' do
        before { get "/api/goals/#{goal_id}/interactions/#{interaction_id}" }

        it 'returns the interaction' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(interaction_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        before { get "/api/goals/#{goal_id}/interactions/1000" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to include("Couldn't find Interaction")
        end
      end
    end

    # Test suite for GET /goal/:goal_id/interactions/:id/check_answer
    describe 'GET /api/goals/:goal_id/interactions/:id/check_answer' do
        before do
          create(:content, :criterion, interaction: interaction)
          get "/api/goals/#{goal_id}/interactions/#{interaction_id}/check_answer?answer=wrong"
        end

      it 'returns the check results' do
        expect(json).not_to be_empty
        expect(json['correct']).to eq(false)
        expect(json['score']).not_to eq(1)
        expect(json['predicted']).not_to eq('')
      end
    end

    # Test suite for POST /goal/:goal_id/interactions/:id/submit_review
    describe 'POST /api/goals/:goal_id/interactions/:id/submit_review' do
      before do
        Fae::User.create(first_name: 'Test', last_name: 'user', password: 'testtest',
                         email: 'test@test.com', role_id: 10)
        create(:content, :criterion, interaction: interaction)
        post "/api/goals/#{goal_id}/interactions/#{interaction_id}/submit_review",
            params: { goal_id: goal_id, id: interaction_id, round: 0, answer: 'Test', score: 90, correct: true, review: true }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the submit review results' do
        expect(json).not_to be_empty
        expect(json['round']).not_to be_nil
        expect(json['response']).not_to be_nil
      end
    end


    # Test suite for POST /goals/:goal_id/interactions
    describe 'POST /api/goals/:goal_id/interactions' do
      # valid payload
      context 'when the request is valid' do
        before { post "/api/goals/#{goal_id}/interactions", params: valid_attributes }

        it 'creates a interaction' do
          expect(json['title']).to eq('Tom Hanks')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid' do
        before { post "/api/goals/#{goal_id}/interactions", params: { title: "Meryl Streep"} }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
              .to match(/Validation failed: Answer type is not included in the list/)
        end
      end
    end

    # Test suite for PUT /goals/:goal_id/interactions/:id
    describe 'PUT /api/goals/:goal_id/interactions/:id' do

      context 'when the record exists' do
        before { put "/api/goals/#{goal_id}/interactions/#{interaction_id}", params: valid_attributes }

        it 'updates the record' do
          expect(response.body).to be_empty
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when the record does not exists' do
        before { put "/api/goals/#{goal_id}/interactions/100", params: valid_attributes }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end


    end

    # Test suite for DELETE /goals/:goal_id/interactions/:id
    describe 'DELETE /api/goals/:goal_id/interactions/:id' do

      context 'when the record exists' do
        before { delete "/api/goals/#{goal_id}/interactions/#{interaction_id}" }

          it 'returns status code 204' do
            expect(response).to have_http_status(204)
          end
        end

      context 'when the record does not exists' do
        before { delete "/api/goals/#{goal_id}/interactions/100" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end