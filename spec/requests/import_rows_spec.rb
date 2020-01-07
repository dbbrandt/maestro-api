# spec/requests/import_rows_spec.rb
require 'rails_helper'

RSpec.describe 'import_rows API', type: :request do
  # initialize test data
  let!(:goal) { create(:goal) }
  let!(:import_file) { create(:import_file, goal: goal) }
  let!(:import_file_id) { import_file.id }
  let!(:import_row) { create(:import_row, import_file: import_file)}
  let!(:import_rows) { create_list(:import_row, 9, import_file: import_file) }
  let(:import_row_id) { import_rows.first.id }
  let(:valid_attributes) { { title: "Tom Hanks", json_data: "{\"title\": \"#{Faker::Lorem.word}\",\"answer_type\": \"ShortAnswer\",\"prompt\": #{Faker::Lorem.sentences(1)},\"criterion1\": #{Faker::Lorem.sentences(1)},\"copy1\": #{Faker::Lorem.sentences(1)},\"points1\": \"1\"}"  } }
  let(:invalid_json_data) { { title: "Tom Hanks", json_data: "{\"title\": \"\",\"answer_type\": \"LongAnswer\",\"prompt\": \"\",\"criterion1\": \"\",\"copy1\": #{Faker::Lorem.sentences(1)},\"points1\": \"0\"}"  } }


  # Test reject requests that are not permitted for this resource
  context 'requests without a import_file specified should fail' do
    describe 'GET /api/import_rows' do
      it 'fails to find the route' do
        expect{ get "/api/import_row" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/import_rows/:id' do
      it 'fails to find the route' do
        expect{ get "/api/import_rows/#{import_row_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'PUT /interactions/:id' do
      it 'fails to find the route' do
        expect{ put "/import_rows/#{import_row_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /api/import_rows' do
      it 'fails to find the route' do
        expect{ post "/api/import_rows" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'DELETE /import_rows/:id' do
      it 'fails to find the route' do
        expect{ delete "/import_rows/#{import_row_id}" }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # Test requests that scoped  to the import_file
  context 'requests an import_file''s import_rows' do
    # Test suite for GET /api/import_files/:import_file_id/import_rows
    describe 'GET /api/import_files/:import_file_id/import_rows' do
      # make HTTP get request before each example
      before { get "/api/import_files/#{import_file_id}/import_rows" }

      it 'returns import_rows' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    # Test suite for GET /api/import_files/:import_file_id/import_rows/:id
    describe 'GET /api/import_files/:import_file_id/import_rows/:id' do
      context 'when the record exists' do
        before { get "/api/import_files/#{import_file_id}/import_rows/#{import_row_id}" }

        it 'returns the import_row' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(import_row_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'when the record does not exist' do
        before { get "/api/import_files/#{import_file_id}/import_rows/1000" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to include("Couldn't find ImportRow")
        end
      end
    end

    # Test suite for POST /api/import_files/:import_file_id/import_rows
    describe 'POST /api/import_files/:import_file_id/import_rows' do
      # valid payload
      context 'when the request is valid' do
        before { post "/api/import_files/#{import_file_id}/import_rows", params: valid_attributes }

        it 'creates an import_row' do
          expect(json['title']).to eq('Tom Hanks')
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request is invalid' do
        context 'when the json is blank' do
          before { post "/api/import_files/#{import_file_id}/import_rows", params: { title: "Meryl Streep"} }

          it 'returns status code 422' do
            expect(response).to have_http_status(422)
          end

          it 'returns a validation failure message' do
            expect(response.body).to match(/Validation failed: Json data can't be blank./)
          end
        end

        context 'when the title is a duplicate' do
          before do
            post "/api/import_files/#{import_file_id}/import_rows", params: valid_attributes
            post "/api/import_files/#{import_file_id}/import_rows", params: valid_attributes
          end

          it 'returns status code 422' do
            expect(response).to have_http_status(422)
          end

          it 'returns a validation failure message' do
            expect(response.body).to match(/Validation failed: Title has already been taken, Title must be unique./)
          end
        end

        context 'when the json has invalid data' do
          before { post "/api/import_files/#{import_file_id}/import_rows", params: invalid_json_data }

          it 'returns status code 422' do
            expect(response).to have_http_status(422)
          end

          it 'returns a validation failure message' do
            expect(response.body).to match(/Validation failed: Prompt can't be blank./)
            expect(response.body).to match(/Answer type must be a valid type/)
            expect(response.body).to match(/At least one complete criterion/)
            expect(response.body).to match(/Points : At least one criterion is required to have points./)
          end
        end
      end
    end

    # Test suite for PUT /api/import_files/:import_file_id/import_rows/:id
    describe 'PUT /api/import_files/:import_file_id/import_rows/:id' do

      context 'when the record exists' do
        before { put "/api/import_files/#{import_file_id}/import_rows/#{import_row_id}", params: valid_attributes }

        it 'updates the record' do
          expect(response.body).to be_empty
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end

      context 'when the record does not exists' do
        before { put "/api/import_files/#{import_file_id}/import_rows/100", params: valid_attributes }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end
    end

    # Test suite for DELETE /api/import_files/:import_file_id/import_rows/:id
    describe 'DELETE /api/import_files/:import_file_id/import_rows/:id' do

      context 'when the record exists' do
        before { delete "/api/import_files/#{import_file_id}/import_rows/#{import_row_id}" }

          it 'returns status code 204' do
            expect(response).to have_http_status(204)
          end
        end

      context 'when the record does not exists' do
        before { delete "/api/import_files/#{import_file_id}/import_rows/100" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end