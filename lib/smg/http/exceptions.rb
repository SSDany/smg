module SMG #:nodoc:
  module HTTP #:nodoc:

    class ConnectionError < StandardError

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

    class TimeoutError < ConnectionError

      def initialize(message)
        @message = message
      end

      def to_s
        @message
      end

    end

  end
end

# EOF