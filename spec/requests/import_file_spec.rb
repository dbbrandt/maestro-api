# spec/requests/import_files_spec.rb
require 'rails_helper'

RSpec.describe 'import_file API', type: :request do
  # initialize test data
  let(:csv_filename) { Rails.root.join "spec/fixtures/RubyQuiz.csv" }
  let(:invalid_csv_filename) { Rails.root.join "spec/fixtures/invalid_import.csv" }
  let!(:goal) { create(:goal) }
  let!(:goal_id) { goal.id }
  let!(:import_files) { create_list(:import_file, 10, goal: goal) }
  let(:import_file_id) { import_files.first.id }
  let(:valid_attributes)  { { :title => "#{Faker::Lorem.word}", :csvfile => csv_filename } }
  let(:invalid_csv_attributes)  { { :title => "#{Faker::Lorem.word}", :csvfile => invalid_csv_filename } }

  let(:json_key) { "title" }
  let(:json_value) { "Ruby Developer" }

  # Test reject requests that are not permitted for this resource
  context 'CRUD requests without a goal specified should fail' do
    describe 'GET import_files' do
      it 'fails to find the route' do
        expect{ get "/import_Files" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'GET /api/import_files/:id' do
      it 'fails to find the route' do
        expect{ get "/import_files/#{import_file_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'PUT /import_files/:id' do
      it 'fails to find the route' do
        expect{ put "/import_files/#{import_file_id}" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /import_files' do
      it 'fails to find the route' do
        expect{ post "/import_files" }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'DELETE /import_files/:id' do
      it 'fails to find the route' do
        expect{ delete "/import_files/#{import_file_id}" }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # Test requests that scoped  to the goal
  context 'CRUD requests that are scoped to a goal' do
    # Test suite for GET /api/goal/:goal_id/import_files
    describe 'GET /api/goals/:goal_id/import_files' do
      # make HTTP get request before each example
      before { get "/api/goals/#{goal_id}/import_files" }

      it 'returns import_files' do
        # Note `json` is a custom helper to parse JSON responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      # Test suite for GET /api/goal/:goal_id/import_files/:id
      describe ' GET /api/goal/:goal_id/import_files/:id' do
        context 'when the record exists' do
          before { get "/api/goals/#{goal_id}/import_files/#{import_file_id}" }

          it 'returns the import_file' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(import_file_id)
            expect(json['json_data']).not_to be_empty
          end

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end

        context 'when the record does not exist' do
          before { get "/api/goals/#{goal_id}/import_files/1000" }

          it 'returns status code 404' do
            expect(response).to have_http_status(404)
          end

          it 'returns a not found message' do
            expect(response.body).to include("Couldn't find ImportFile")
          end
        end
      end
    end

    # Test suite for POST /api/goal/:goal_id/import_files
    describe 'POST /api/goal/:goal_id/import_files' do
      # valid payload
      context 'when the request is valid' do
        #For this test the filename is passed as an attribute and is local
        before do
          post "/api/goals/#{goal_id}/import_files", params: valid_attributes

          @import_file_id = json["id"]
          @import_row_count = json["json_data"].size
        end

        it 'creates an import_file' do
          expect( json["json_data"][0][json_key] ).to eq(json_value)
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end

        it 'reads existing import_rows' do
          get "/api/import_files/#{@import_file_id}/import_rows"
          expect( json.size ).to eq(@import_row_count)
        end
      end

      context 'when the request parameter are invalid' do
        before { post "/api/goals/#{goal_id}/import_files", params: { title: "Test Quiz"} }

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
              .to match(/Validation failed: Json data can't be blank/)
        end
      end

      context 'when the csv file has errors' do
        before { post "/api/goals/#{goal_id}/import_files", params: invalid_csv_attributes }

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end

        it 'returns a validation error messages' do
          expect(json["errors"].size).to be > 0
        end
      end
    end


    # Test suite for PUT /api/goal/:goal_id/import_files/:id
    describe 'PUT /api/goal/:goal_id/import_files/:id' do

      context 'when the record exists' do
        # Do the creation twice to verify that the put replaces existing rows.
        before do
          put "/api/goals/#{goal_id}/import_files/#{import_file_id}", params: valid_attributes
          get "/api/import_files/#{import_file_id}/import_rows"
          @first_row_id = json[0]["id"]
          put "/api/goals/#{goal_id}/import_files/#{import_file_id}", params: valid_attributes
        end

        it 'updates the record' do
          expect(response.body).to be_empty
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end

        #insure that new data is imported
        it 'recreates the import_rows' do
          get "/api/import_files/#{import_file_id}/import_rows"
          expect( json[0][:id]).not_to eq(@first_row_id)
        end
      end

      context 'when the record does not exists' do
        before { put "/api/goals/#{goal_id}/import_files/100", params: valid_attributes }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end
    end

    # Test suite for DELETE /api/goal/:goal_id/import_files/:id
    describe 'DELETE /api/goals/:goal_id/import_files/:id' do

      context 'when the record exists' do
        before { delete "/api/goals/#{goal_id}/import_files/#{import_file_id}" }

        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end

      end

      context 'when the record does not exists' do
        before { delete "/api/goals/#{goal_id}/import_files/100" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end
    end

    # Test suite for POST /api/goal/:goal_id/import_files/:id/generate
    describe 'POST /api/goals/:goal_id/import_files/:id/generate' do

      context 'when the import file exists' do
        before { post "/api/goals/#{goal_id}/import_files/#{import_file_id}/generate" }

        it 'returns status code 204' do
          expect(response).to have_http_status(201)
        end

      end

      context 'when the import file does not exists' do
        before { post "/api/goals/#{goal_id}/import_files/100/generate" }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
      end
    end
  end
end