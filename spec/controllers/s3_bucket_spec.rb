require 'rails_helper'

RSpec.describe 'S3Bucket Concern', type: :controller do

  before do
    class S3BucketController < ApplicationController
      include S3Bucket
    end
  end

  let!(:bucket) { S3BucketController.new }

  describe "s3 bucket files" do
    it 'returns files' do
      expect( bucket.s3_bucket_files.length ).to be > 0
    end
  end

  describe "presigned url" do
    it 'returns a url' do
      res =  bucket.s3_presigned_url('test')
      url = res[:url]
      expect( url.length ).to be > 0
      expect( url ).to include 'http'
      expect(url).to include res[:filename]
    end
  end

  describe "bucket_path" do
    it 'returns a bucket path' do
      goal =  create(:goal)
      result =  bucket.s3_bucket_path("goals", goal.id, goal.title, 'test')
      expect( result ).to include 'goals'
      expect( result ).to include goal.id.to_s
      expect( result ).to include 'test'
    end
  end
end
