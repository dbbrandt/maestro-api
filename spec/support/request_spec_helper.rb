# spec/support/request_spec_helper
module RequestSpecHelper
  # Parse JSON response to ruby hash
  def json
    JSON.parse(response.body)
  end

  def headers(params=nil)
    credentials = ActionController::HttpAuthentication::Token.encode_credentials ApplicationController::TOKEN
    headers = { headers: {'HTTP_AUTHORIZATION' => credentials}, params: params }
    headers
  end
end
