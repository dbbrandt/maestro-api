# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  # initialize test data
  let!(:users) { create_list(:user, 10) }
  let!(:user) { users.first }
  let(:user_id) { user.id }
  let(:goals) { create_list(:goal, 10, user: user) }
  let(:goal_id) { goals.first.id }

  # Test suite for GET /users
  describe 'GET /api/userss' do
    # make HTTP get request before each example
    before { get '/api/users' }

    it 'returns goals' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /users/:id
  describe 'GET /api/users/:id' do
    before { get "/api/users/#{user_id}" }

    context 'when the record exists' do
      it 'returns the goal' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:user_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find User/)
      end
    end
  end

  # Test suite for POST /users
  describe 'POST /api/users' do
    # valid payload
    let(:valid_attributes) { { email: 'test@test.com', password: "google", name: 'Test user' } }

    context 'when the request is valid' do
      before { post '/api/users', params: valid_attributes }

      it 'creates a user' do
        expect(json['email']).to eq('test@test.com')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/users', params: nil }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
            .to match(/Validation failed: Password can't be blank/)
      end
    end
  end

  # Test suite for PUT /goals/:id
  describe 'PUT /api/users/:id' do
    let(:valid_attributes) { { name: 'test user' } }

    context 'when the record exists' do
      before { put "/api/users/#{user_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exists' do
      before { put "/api/users/100", params: valid_attributes }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for DELETE /goals/:id
  describe 'DELETE /api/users/:id' do

    context 'when the record exists' do
      before { delete "/api/users/#{user_id}" }
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exists' do
      before { delete "/api/users/100" }
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for DELETE /users/:id/purge
  describe 'DELETE /api/users/:id/purge' do

    context 'when the record exists' do
      before do
        delete "/api/users/#{user_id}/purge"
      end
      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'does not have any goals' do
        get "/api/goals/#{goal_id}?user_id=#{user_id}"
        expect(json).to be_empty
      end
    end

    # Test suite for GET /users/:id/presigned_url
    describe 'GET /api/users/:id/presigned_url' do

      context 'when the filename is passed' do
        before do
          get "/api/userss/#{user_id}/presigned_url?filename=avatar.jpg"
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
          expect(url).to include 'users/'
          name = user.name.gsub(/[^0-9A-Za-z]/, '')
          expect(url).to include "#{user.id}-#{name}/avatar.jpg"
          expect(url).to include json['filename']
        end
      end
    end
  end
end
