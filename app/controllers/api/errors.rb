module Api
  module Errors
    class ApiError < StandardError
      attr_reader :message
      def initialize(message = nil)
        @message = message || cause.message
      end
    end

    class BadRequestError < ApiError
    end
  end
end
