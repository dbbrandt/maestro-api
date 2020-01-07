require 'rails_helper'

RSpec.describe 'CSV Controller Concern', type: :controller do

  let(:csv_filename) { "temp.csv" }
  let(:json_key) { "title" }
  let(:json_value) { "Downside of strings" }

  before do
    class ImportController < ApplicationController
      include CsvLoader
    end

    CSV.open(csv_filename, 'wb') do |csv|
      csv << [json_key, "answer_type", "prompt", "criterion1",	"copy1",	"points1", "criterion2",	"copy2",	"points2"]
      csv << [json_value, "ShortAnswer", "What is downside...", "performance",	"String comparison is...", 1,
                                                                           "memory use",	"String comparison is...", 1]
    end
  end
  after do
    File.delete(csv_filename)
  end

  let(:importer) { ImportController.new }

  describe "load csv file" do
    before do
      importer.load(csv_filename)
    end

    it 'loads the correct data into json' do
      expect( JSON.parse(importer.json_data)[0][json_key] ).to eq(json_value)
    end

  end
end