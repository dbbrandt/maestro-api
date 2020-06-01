# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  # initialize test data
  let!(:admin_user) { create(:admin_user) }
  let!(:admin_user_id) { admin_user.id }
  let(:users) { create_list(:user, 10) }
  let(:user) { users.first }
  let(:user_id) { user.id }
  let(:email) { user.email }
  let(:valid_attributes) { { email: 'test@test.com', password: "google", name: 'Test user' } }


  before { set_token(user_id) }

  # Test suite for GET /users
  describe 'GET /api/users' do
    # make HTTP get request before each example

    context 'when the user is an admin' do
      before do
        set_token(admin_user_id)
        get '/api/users', headers
        get '/api/users', headers
      end

      it 'returns users' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(11)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user is not an admin' do
      before do
        get '/api/users', headers
      end

      it 'returns users' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(1)
        expect(json[0]["id"]).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /users/:id
  describe 'GET /api/users/:id' do

    context 'when the record exists' do
      before do
        set_token(user_id)
        get "/api/users/#{user_id}", headers
      end

      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      before do
        set_token(admin_user_id)
        get "/api/users/999", headers
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find User/)
      end
    end

    context 'when the user_id is invalid for the requesting user' do
      before do
        set_token(user_id)
        get "/api/users/999", headers
      end

      it 'returns status code 403 Forbidden' do
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for POST /users
  describe 'POST /api/users' do
    context 'when the request is valid' do
      before { post '/api/users', app_headers(valid_attributes) }

      it 'creates a user' do
        expect(json['email']).to eq('test@test.com')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/users', app_headers }

      it 'returns status code 403' do
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
      before { put "/api/users/#{user_id}", headers(valid_attributes) }

      it 'updates the record' do
        expect(response.body).not_to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user_id is invalid' do
      before do
        # Requesting a non-existent user can only be done by admin
        put "/api/users/999", headers(valid_attributes)
      end

      it 'returns status code 403 Forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the record does not exists' do
      before do
        # Requesting a non-existent user can only be done by admin
        set_token(admin_user_id)
        put "/api/users/999", headers(valid_attributes)
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end


  # Test suite for DELETE /goals/:id
  describe 'DELETE /api/users/:id' do
    before { set_token(admin_user_id)}

    context 'when the record exists' do

      it 'returns status code 204' do
        delete "/api/users/#{user_id}", headers
        expect(response).to have_http_status(204)
      end
    end

    context 'when the record does not exists' do
      it 'returns status code 404' do
        delete "/api/users/999", headers
        expect(response).to have_http_status(404)
      end
    end

    context 'when the user is not admin' do
      it 'returns status code 403 Forbidden' do
        set_token(user_id)
        delete "/api/users/#{user_id}", headers
        expect(response).to have_http_status(403)
      end
    end
  end

  # Test suite for DELETE /users/:id/purge
  describe 'DELETE /api/users/:id/purge' do

    context 'when the record exists' do
      let!(:user_id) { user.id }
      let!(:goals) { create_list(:goal, 10, user: user) }
      let!(:goal_id) { goals.first.id }


      before do
        delete "/api/users/#{user_id}/purge", headers
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'does not have any goals' do
        result = user.goals
        expect(result).to be_empty
      end
    end

    # Test suite for GET /users/:id/presigned_url
    describe 'GET /api/users/:id/presigned_url' do

      context 'when the filename is passed' do
        before do
          get "/api/users/#{user_id}/presigned_url?filename=avatar.jpg", headers
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
