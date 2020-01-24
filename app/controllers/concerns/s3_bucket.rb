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
    url = s3_presigner(key)
    filename = url.match(/(^.*)\?/)[1]
    { url: url, filename: filename }
  end

  def s3_presigner(key)
    @signer.presigned_url(:put_object, bucket: @bucket, key: key)
  end

  def s3_bucket_path(goal, filename)
    return unless goal
    name = goal.title.gsub(/[^0-9A-Za-z]/, '')
    "goals/#{goal.id}-#{name}/#{filename}"
  end
end


