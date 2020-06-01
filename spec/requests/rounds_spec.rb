# spec/requests/round_spec.rb
require 'rails_helper'

RSpec.describe 'rounds API', type: :request do
  let!(:user) { create(:user) }
  let!(:user_id) { user.id }
  let!(:goal) { create(:goal, user: user) }
  let!(:goal_id) { goal.id }
  let!(:rounds) { create_list(:round, 10, goal: goal, user: user) }
  let!(:round) { rounds.first }
  let!(:responses) {  create_list(:round_response, 10, round: round ) }
  let(:round_id) { round.id }

  before { set_token(user_id) }

  context 'requests without a goal specified should fail' do
    describe 'GET /api/rounds' do
      it 'fails to find the route' do
        expect{ get "/api/rounds", headers }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/rounds/:id' do
      it 'fails to find the route' do
        expect{ get "/api/rounds/#{round_id}", headers }.to raise_error(ActionController::RoutingError)
      end
    end
  
    describe 'PUT /api/rounds/:id' do
      it 'fails to find the route' do
        expect{ put"/api/rounds/#{round_id}", headers }.to raise_error(ActionController::RoutingError)
      end
    end
  
    describe 'POST /api/rounds' do
      it 'fails to find the route' do
        expect{ post "/api/rounds", headers }.to raise_error(ActionController::RoutingError)
      end
    end
  
    describe 'DELETE /api/rounds/:id' do
      it 'fails to find the route' do
        expect{ delete"/api/rounds/#{round_id}", headers }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  context 'requests with a goal' do
    # Test suite for GET /goal/:goal_id/rounds
    describe 'GET /api/goals/:goal_id/rounds' do
      # make HTTP get request before each example
      before do
        get "/api/goals/#{goal_id}/rounds", headers
      end

      it 'returns rounds' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET /api/goals/:goal_id/rounds' do
      # make HTTP get request before each example
      before do
        get "/api/goals/#{goal_id}/rounds?", headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns response counts' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json[0]).not_to be_nil
        expect(json[0]['total']).to eq(10)
      end
    end

    describe 'GET /api/goals/:goal_id/rounds deep responses' do
      # make HTTP get request before each example
      before do
        get "/api/goals/#{goal_id}/rounds?deep=true", headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns responses' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json[0]).not_to be_nil
        res = json[0]["round_responses"]
        expect(res.count).to eq(10)
      end
    end

    describe 'GET /api/goals/:goal_id/rounds/:id' do
      # make HTTP get request before each example
      before do
        get "/api/goals/#{goal_id}/rounds/#{round_id}", headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns round' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json['id']).to eq(round_id)
      end
    end

    describe 'GET /api/goals/:goal_id/rounds/:id deep responses' do
      # make HTTP get request before each example
      before do
        get "/api/goals/#{goal_id}/rounds/#{round_id}?deep=true", headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns round' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json['round_responses'].length).to eq(10)
      end
    end

  end
end
