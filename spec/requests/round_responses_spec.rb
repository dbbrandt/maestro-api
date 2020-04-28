# spec/requests/round_responses_spec.rb
require 'rails_helper'

RSpec.describe 'round responses API', type: :request do
  let!(:user) { create(:user) }
  let!(:goal) { create(:goal) }
  let!(:goal_id) { goal.id }
  let!(:rounds) { create_list(:round, 10, goal: goal, user: user) }
  let!(:round) { rounds.first }
  let!(:round_responses) {  create_list(:round_response, 10, round: round ) }
  let!(:round_response) { round_responses.first }
  let(:round_id) { round.id }
  let(:response_id) { round_response.id }

  context 'requests without a goal specified should fail' do
    describe 'GET /api/round_responses' do
      it 'fails to find the route' do
        expect{ get "/api/round_responses" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/round_responses/:id' do
      it 'fails to find the route' do
        expect{ get "/api/round_responses/#{response_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'PUT /api/round_responses/:id' do
      it 'fails to find the route' do
        expect{ put"/api/round_responses/#{response_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /api/round_responses' do
      it 'fails to find the route' do
        expect{ post "/api/round_responses" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'DELETE /api/round_responses/:id' do
      it 'fails to find the route' do
        expect{ delete"/api/round_responses/#{response_id}" }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  context 'requests with a goal' do
    # Test suite for GET /goal/:goal_id/rounds/:id/round_responses
    describe 'GET /api/goals/:goal_id/rounds/:id/round_responses' do
      # make HTTP get request before each example
      before do
        get "/api/goals/#{goal_id}/rounds/#{round_id}/round_responses?user_id=#{user.id}"
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns rounds' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

    end
  end

  describe 'GET /api/goals/:goal_id/rounds/:round_id/round_responses/:id' do
    # make HTTP get request before each example
    before do
      get "/api/goals/#{goal_id}/rounds/#{round_id}/round_responses/#{response_id}?user_id=#{user.id}"
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns round response' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json['id']).to eq(response_id)
    end
  end

end
