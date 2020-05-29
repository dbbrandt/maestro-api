# app/controllers/concerns/response.rb
module ResponseHandler
  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def bad_request(message)
    render json: {message: message}, status: :bad_request
  end

  def forbidden_request(message)
    render json: {message: message}, status: :forbidden
  end
end
