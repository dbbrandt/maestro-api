# spec/support/request_spec_helper
module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end

  def set_token(user_id)
    @token = ApplicationController.new.encode_auth_token(user_id)
  end

  def headers(params=nil)
    build_header("Bearer " + @token, params)
  end

  # User for non-user app requests
  def app_headers(params=nil)
    build_header("Bearer " + ApplicationController::SECRET, params)
  end

  private
  def build_header(credentials, params)
    { headers: {'HTTP_AUTHORIZATION' => credentials}, params: params }
  end
end
