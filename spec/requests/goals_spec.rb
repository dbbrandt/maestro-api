# spec/requests/goals_spec.rb
require 'rails_helper'

#TODO Replace user_id param in most requests with authenticated user logic.
RSpec.describe 'Goals API', type: :request do
  # initialize test data
  let!(:admin_user) { create(:admin_user) }
  let!(:admin_user_id) { admin_user.id }
  let(:user) { create(:user) }
  let(:user_id) { user.id }
  let!(:goals) { create_list(:goal, 10) }
  let(:goal) { goals.first }
  let(:goal_id) { goal.id }
  let(:user_id) { goal.user_id }
  let!(:other_goal) { create(:goal) }
  let(:other_user_id) { other_goal.user_id }

  # Test suite for GET /goals
  describe 'GET /api/goals' do
    # make HTTP get request before each example
    context 'by admin user' do
      before do
        set_token(admin_user_id)
        get '/api/goals', headers
      end

      it 'returns goals' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(11)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'by other user' do
      before do
        set_token(other_user_id)
        get '/api/goals', headers
      end

      it 'returns users goal' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /goals/:id
  describe 'GET /api/goals/:id' do
    before do
      set_token(user_id)
      get "/api/goals/#{goal_id}", headers
    end

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
    let(:valid_attributes) { { title: 'Learn Actor Names', user_id: user_id } }

    context 'when the request is valid' do
      before do
        set_token(user_id)
        post '/api/goals', headers(valid_attributes)
      end

      it 'creates a goal' do
        expect(json['title']).to eq('Learn Actor Names')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before do
        set_token(user_id)
        post '/api/goals', headers
      end

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
      before do
        set_token(user_id)
        put "/api/goals/#{goal_id}?user_id=#{user_id}", headers(valid_attributes)
      end

      it 'updates the record' do
        expect(response.body).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exists' do
      before do
        set_token(admin_user_id)
        put "/api/goals/100?user_id=#{user_id}", headers(valid_attributes)
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for DELETE /goals/:id
  describe 'DELETE /api/goals/:id' do

    context 'when the record exists' do
      before do
        set_token(user_id)
        delete "/api/goals/#{goal_id}?user_id=#{user_id}", headers
      end
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exists' do
      before do
        set_token(admin_user_id)
        delete "/api/goals/100", headers
      end
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for DELETE /goals/:id/purge
  describe 'DELETE /api/goals/:id/purge' do

    context 'when the record exists' do
      before do
        set_token(user_id)
        create_list(:interaction, 10, goal: goals.first)
        delete "/api/goals/#{goal_id}/purge?user_id=#{user_id}", headers
      end
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'does not have any interactions' do
        get "/api/goals/#{goal_id}/interactions", headers
        expect(json).to be_empty
      end
    end
  end

  # Test suite for GET /goals/:id/presigned_url
  describe 'GET /api/goals/:id/presigned_url' do

    context 'when the filename is passed' do
      before do
        set_token(admin_user_id)
        get "/api/goals/#{goal_id}/presigned_url?filename=test", headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a url' do
        expect(json['url']).not_to be_nil
      end

      it 'returns a url with the proper file path' do
        url = json['url']
        expect(url).to include 'http'
        expect(url).to include 'goals/'
        name = goal.title.gsub(/[^0-9A-Za-z]/, '')
        expect(url).to include "#{goal.id}-#{name}/test"
        expect(url).to include json['filename']
      end
    end

    context 'when the filename is not passed' do
      before do
        set_token(user_id)
        get "/api/goals/#{goal_id}/presigned_url?user_id=#{user_id}", headers
      end

      it 'returns status code 400 bad request' do
        expect(response).to have_http_status(400)
      end
    end
  end
end
