# spec/support/request_spec_helper
module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end

  def set_user(user_id)
    @token = ApplicationController.new.encode_auth_token(user_id)
  end

  def headers(params=nil)
    credentials = "Bearer " + @token
    headers = { headers: {'HTTP_AUTHORIZATION' => credentials}, params: params }
    headers
  end
end
