module Spec #:nodoc:
  module Helpers #:nodoc:
    module HTTPHelpers

      def http(uri, options = {})
        timeout = options[:timeout] || SMG::HTTP::Request::DEFAULT_TIMEOUT
        times = options[:times] || 1
        uri = Addressable::URI.parse(uri)
        @http ||= mock('http')
        Net::HTTP.should_receive(:start).
        with(uri.host, uri.port).exactly(times).times.and_yield(@http)
        @http.should_receive(:open_timeout=).with(timeout).exactly(times)
        @http.should_receive(:read_timeout=).with(timeout).exactly(times)
      end

      def stub_response(code, message, *args)
        response = Net::HTTPResponse::CODE_TO_OBJ[code.to_s].new('1.1', code, message)
        response.initialize_http_header(Hash === args.last ? args.pop : {})
        response.stub!(:body).and_return(args.join) unless args.empty?
        @http.should_receive(:request).and_return response
        response
      end

    end
  end
end

# EOF