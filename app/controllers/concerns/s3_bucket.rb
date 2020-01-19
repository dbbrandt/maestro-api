require 'aws-sdk-s3'  # v2: require 'aws-sdk'
require 'json'

module S3Bucket
  def initialize
    @region = "us-east-1"
    @bucket = 'memory-maestro'
    @s3 = Aws::S3::Client.new
    @signer =  Aws::S3::Presigner.new({client: @s3})
  end

  def s3_bucket_files(prefix = nil)
    res = @s3.list_objects({bucket: @bucket, prefix: prefix})
    res.contents.map { |f| f.key }
  end

  def s3_presigned_url(key)
    resource = Aws::S3::Resource.new(client: @s3)
    bucket = resource.bucket(@bucket)
    obj = bucket.object(key)
    obj.presigned_url(:put)
  end

  def s3_bucket_path(goal, filename)
    return unless goal
    name = goal.title.gsub(/[^0-9A-Za-z]/, '')
    "#{goal.id}-#{name}/#{filename}"
  end
end


