# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  # initialize test data
  let!(:admin_user) { create(:admin_user) }
  let!(:admin_user_id) { admin_user.id }
  let(:users) { create_list(:user, 10) }
  let(:user) { users.first }
  let(:user_id) { user.id }
  let(:email) { user.email }
  let(:valid_attributes) { { email: email } }
  let(:invalid_attributes) { { id: user_id } }


  # Test suite for POST /authorize
  describe 'POST /api/authorize' do
    # make HTTP get request before each example
    context 'valid headers' do
      before do
        post '/api/authorize', app_headers(valid_attributes)
      end

      it 'returns a valid token' do
        expect(json).not_to be_empty
        token = json["auth_token"]
        expect(token).not_to be_empty
        payload = JWT.decode(token, ApplicationController::SECRET)[0]
        expect(payload["user_id"]).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'invalid parameters' do
      before do
        post '/api/authorize', app_headers(invalid_attributes)
      end

      it 'returns a valid token' do
        expect(json).to be_nil
      end

      it 'returns status code 403 forbidden' do
        expect(response).to have_http_status(403)
      end
    end

    context 'user token with invalid attributes' do
      before do
        set_token(user_id)
        post '/api/authorize', headers(invalid_attributes)
      end

      it 'returns the same valid token' do
        expect(json).not_to be_empty
        expect(json["auth_token"]).to eq(@token)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'invalid token' do
      before do
        set_token(99)
        post '/api/authorize', headers(valid_attributes)
      end

      it 'returns the same Invalid Token' do
        expect(body).not_to be_empty
        expect(body).to match(/HTTP Token: Access denied/)
      end

      it 'returns status code 401 Unauthorized' do
        expect(response).to have_http_status(401)
      end
    end
  end
end
