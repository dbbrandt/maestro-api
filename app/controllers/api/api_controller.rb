#rubocop:disable all
module Api
  class ApiController < ApplicationController
    rescue_from Api::Errors::BadRequestError, with: :bad_request!
    rescue_from StandardError, with: :internal_server_error!

    def ok!(content)
      if (content)
        render json: content
      else
        head :ok
      end
    end

    def no_content!
      head :no_content
    end

    def forbidden!
      head :forbidden
    end

    def bad_request!(exception = nil)
      error!(:bad_request, exception)
    end

    def internal_server_error!(exception = nil)
      error!(:internal_server_error, exception)
    end

    def not_found!(exception = nil)
      error!(:not_found, exception)
    end

    def error!(status, exception = nil)
      if exception
        render json: {
            exception: exception.class.name,
            message: exception.message,
            backtrace: exception.backtrace
        }, status: status
      else
        head status
      end
    end

    def authorize_role(role = 'ecommerce')
      forbidden! unless @current_user.has_role?(role)
    end
  end
end