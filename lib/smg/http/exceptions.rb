module SMG #:nodoc:
  module HTTP #:nodoc:

    class ConnectionError < StandardError

      attr_reader :response

      def initialize(response, message = nil)
        @response = response
        @message = message
      end

      def to_s
        message =  "Action failed with code: #{@response.code}."
        message << " Message: #{@response.message}" if @response.respond_to?(:message)
        message
      end

    end

    class RedirectionError < ConnectionError
    end

    class TimeoutError < ::Timeout::Error
    end

    class SSLError < StandardError
    end

  end
end

# EOF