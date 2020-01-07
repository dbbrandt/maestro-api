# spec/requests/goals_spec.rb
require 'rails_helper'

RSpec.describe 'Goals API', type: :request do
  # initialize test data 
  let!(:goals) { create_list(:goal, 10) }
  let(:goal_id) { goals.first.id }

  # Test suite for GET /goals
  describe 'GET /api/goals' do
    # make HTTP get request before each example
    before { get '/api/goals' }

    it 'returns goals' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /goals/:id
  describe 'GET /api/goals/:id' do
    before { get "/api/goals/#{goal_id}" }

    context 'when the record exists' do
      it 'returns the goal' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(goal_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:goal_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Goal/)
      end
    end
  end

  # Test suite for POST /goals
  describe 'POST /api/goals' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Actor Names' } }

    context 'when the request is valid' do
      before { post '/api/goals', params: valid_attributes }

      it 'creates a goal' do
        expect(json['title']).to eq('Learn Actor Names')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/goals', params: nil }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
            .to match(/Validation failed: Title can't be blank/)
      end
    end
  end

  # Test suite for PUT /goals/:id
  describe 'PUT /api/goals/:id' do
    let(:valid_attributes) { { title: 'Learn Actors Movies' } }

    context 'when the record exists' do
      before { put "/api/goals/#{goal_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exists' do
      before { put "/api/goals/100", params: valid_attributes }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for DELETE /goals/:id
  describe 'DELETE /api/goals/:id' do

    context 'when the record exists' do
      before { delete "/api/goals/#{goal_id}" }
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exists' do
      before { delete "/api/goals/100" }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for DELETE /goals/:id/purge
  describe 'DELETE /api/goals/:id/purge' do

    context 'when the record exists' do
      before do
        create_list(:interaction, 10, goal: goals.first)
        delete "/api/goals/#{goal_id}/purge"
      end
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'does not have any interactions' do
        get "/api/goals/#{goal_id}/interactions"
        expect(json).to be_empty
      end

    end
  end
end
