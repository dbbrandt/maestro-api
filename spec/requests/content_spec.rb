# spec/requests/contents_spec.rb
require 'rails_helper'

RSpec.describe 'Contents API', type: :request do
  # initialize test data
  let!(:user) { create(:user) }
  let!(:user_id) { user.id}
  let!(:goal) { create(:goal) }
  let!(:interaction) { create(:interaction, goal: goal) }
  let!(:interaction_id) { interaction.id }
  let!(:contents) { create_list(:content, 10, interaction: interaction) }
  let(:content_id) { contents.first.id }
  let(:valid_prompt) { {title: 'Tom Hanks', content_type: 'Prompt' , copy: 'Test'} }
  let(:valid_criterion) { {title: 'Tom Hanks', content_type: 'Criterion' , descriptor: 'Test'} }

  before { set_token(user_id) }

  # Test reject requests that are not permitted for this resource
  context 'requests without a interaction specified should fail' do
    describe 'GET /api/content' do
      it 'fails to find the route' do
        expect{ get "/api/content", headers }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/contents/:id' do
      it 'fails to find the route' do
        expect{ get "/api/contents/#{content_id}", headers }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'PUT /api/contents/:id' do
      it 'fails to find the route' do
        expect{ put "/api/contents/#{content_id}", headers }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /api/contents' do
      it 'fails to find the route' do
        expect{ post "/api/contents", headers }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'DELETE /api/contents/:id' do
      it 'fails to find the route' do
        expect{ delete "/api/contents/#{content_id}", headers }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # Test requests that scoped  to the interaction
  context 'requests a interaction''s contents' do
    # Test suite for GET /api/interaction/:interaction_id/contents
    describe 'GET /api/interactions/:interaction_id/contents' do
      # make HTTP get request before each example
      before { get "/api/interactions/#{interaction_id}/contents", headers }

      it 'returns contents' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    # Test suite for GET /api/interaction/:interaction_id/contents/:id
    describe 'GET /api/interaction/:interaction_id/contents/:id' do
      context 'when the record exists' do
        before { get "/api/interactions/#{interaction_id}/contents/#{content_id}", headers }

        it 'returns the interaction' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(content_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        before { get "/api/interactions/#{interaction_id}/contents/999",  headers }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to include("Couldn't find Content")
        end
      end
    end

    # Test suite for POST /api/interaction/:interaction_id/contents
    describe 'POST /api/interaction/:interaction_id/contents' do
      # valid payload
      context 'when the request is a valid' do
        before { post "/api/interactions/#{interaction_id}/contents", headers(valid_prompt) }

        it 'creates prompt contents' do
          expect(json['title']).to eq('Tom Hanks')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid' do
        before { post "/api/interactions/#{interaction_id}/contents", headers({ title: "Meryl Streep", copy: "test"}) }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
              .to match(/Validation failed: Content type is not included in the list/)
        end
      end

      context 'when the request is invalid prompt' do
        before { post "/api/interactions/#{interaction_id}/contents",
                      headers({ title: "Meryl Streep", content_type: "Prompt"}) }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
              .to match(/Prompt must have a stimulus image or copy/)
        end
      end

      context 'when the request is a valid criterion' do
        before { post "/api/interactions/#{interaction_id}/contents", headers(valid_criterion) }

        it 'creates a interaction' do
          expect(json['title']).to eq('Tom Hanks')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid criterion' do
        before { post "/api/interactions/#{interaction_id}/contents",
                      headers( {title: "Meryl Streep", content_type: "Criterion", copy: "test"} ) }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
              .to match(/Criterion must have a descriptor/)
        end
      end
    end

    # Test suite for PUT /api/interaction/:interaction_id/contents/:id
    describe 'PUT /api/interaction/:interaction_id/contents/:id' do

      context 'when the record exists' do
        before { put "/api/interactions/#{interaction_id}/contents/#{content_id}", headers(valid_prompt) }

        it 'updates the record' do
          expect(response.body).to be_empty
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when the record does not exists' do
        before { put "/api/interactions/#{interaction_id}/contents/999", headers(valid_prompt) }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end


    end

    # Test suite for DELETE /api/interaction/:interaction_id/contents/:id
    describe 'DELETE /api/interactions/:interaction_id/contents/:id' do

      context 'when the record exists' do
        before { delete "/api/interactions/#{interaction_id}/contents/#{content_id}", headers }

          it 'returns status code 204' do
            expect(response).to have_http_status(204)
          end
        end

      context 'when the record does not exists' do
        before { delete "/api/interactions/#{interaction_id}/contents/#{content_id}", headers }

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
