module Spec #:nodoc:
  module Helpers #:nodoc:
    module HTTPHelpers

      def http(uri, proxy = nil)
        @http ||= mock('http')
        uri = Addressable::URI.parse(uri)
        args = (proxy && p = Addressable::URI.parse(proxy)) ?
          [uri.host, uri.port, p.host, p.port, p.user, p.password] :
          [uri.host, uri.port]

        Net::HTTP.should_receive(:new).with(*args).and_return(@http)
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