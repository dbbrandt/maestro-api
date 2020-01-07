# spec/requests/contents_spec.rb
require 'rails_helper'

RSpec.describe 'Contents API', type: :request do
  # initialize test data
  let!(:goal) { create(:goal) }
  let!(:interaction) { create(:interaction, goal: goal) }
  let!(:interaction_id) { interaction.id }
  let!(:contents) { create_list(:content, 10, interaction: interaction) }
  let(:content_id) { contents.first.id }
  let(:valid_attributes) { { title: 'Tom Hanks', content_type: 'Prompt' , copy: 'Test'} }

  # Test reject requests that are not permitted for this resource
  context 'requests without a interaction specified should fail' do
    describe 'GET /api/content' do
      it 'fails to find the route' do
        expect{ get "/api/content" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/contents/:id' do
      it 'fails to find the route' do
        expect{ get "/api/contents/#{content_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'PUT /api/contents/:id' do
      it 'fails to find the route' do
        expect{ put "/api/contents/#{content_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /api/contents' do
      it 'fails to find the route' do
        expect{ post "/api/contents" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'DELETE /api/contents/:id' do
      it 'fails to find the route' do
        expect{ delete "/api/contents/#{content_id}" }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # Test requests that scoped  to the interaction
  context 'requests a interaction''s contents' do
    # Test suite for GET /api/interaction/:interaction_id/contents
    describe 'GET /api/interactions/:interaction_id/contents' do
      # make HTTP get request before each example
      before { get "/api/interactions/#{interaction_id}/contents" }

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
        before { get "/api/interactions/#{interaction_id}/contents/#{content_id}" }

        it 'returns the interaction' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(content_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        before { get "/api/interactions/#{interaction_id}/contents/1000" }

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
      context 'when the request is valid' do
        before { post "/api/interactions/#{interaction_id}/contents", params: valid_attributes }

        it 'creates a interaction' do
          expect(json['title']).to eq('Tom Hanks')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid' do
        before { post "/api/interactions/#{interaction_id}/contents", params: { title: "Meryl Streep", copy: "test"} }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
              .to match(/Validation failed: Content type is not included in the list/)
        end
      end
    end

    # Test suite for PUT /api/interaction/:interaction_id/contents/:id
    describe 'PUT /api/interaction/:interaction_id/contents/:id' do

      context 'when the record exists' do
        before { put "/api/interactions/#{interaction_id}/contents/#{content_id}", params: valid_attributes }

        it 'updates the record' do
          expect(response.body).to be_empty
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when the record does not exists' do
        before { put "/api/interactions/#{interaction_id}/contents/100", params: valid_attributes }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end


    end

    # Test suite for DELETE /api/interaction/:interaction_id/contents/:id
    describe 'DELETE /api/interactions/:interaction_id/contents/:id' do

      context 'when the record exists' do
        before { delete "/api/interactions/#{interaction_id}/contents/#{content_id}" }

          it 'returns status code 204' do
            expect(response).to have_http_status(204)
          end
        end

      context 'when the record does not exists' do
        before { delete "/api/interactions/#{interaction_id}/contents/#{content_id}" }

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end
