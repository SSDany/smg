require 'smg/http/request'
require 'smg/http/exceptions'
require 'smg/http/hooks'

module SMG #:nodoc:
  module HTTP #:nodoc:

    VERBS = Hash[ Request::VERBS.map { |v| v.to_s.gsub(/^.*::/,'').downcase.to_sym }.zip(Request::VERBS) ]

    module Model

      HTTP::VERBS.keys.each do |verb|
        self.class_eval(<<-EOS, __FILE__, __LINE__ + 1)
          def #{verb}(path, options = {})
            http(:#{verb}, path, options)
          end
        EOS
      end

      def site(value)
        @site = value
      end

      def params(value)
        @params = value
      end

      def on_parse(&block)
        raise ArgumentError, "No block given" unless block_given?
        @on_parse = block
      end

      private

      def http(verb, path, options = {})
        options = options.dup
        request = SMG::HTTP::Request.new(HTTP::VERBS[verb], uri_for(path,options.delete(:query)), options)
        run_callbacks(:before_request, request, :verb => verb)
        response = request.perform
        run_callbacks(:after_request, response, :verb => verb)
        parse @on_parse ? @on_parse[response.body] : response.body
      end

      def uri_for(path, query = nil)
        raise "site URI missed" unless @site
        ret = Addressable::URI.parse(@site)
        ret.path = path
        qvalues = {}
        qvalues.update(@params) if @params
        qvalues.update(query) if query
        ret.query_values = qvalues unless qvalues.empty?
        ret
      end

    end

    def self.append_features(base)
      base.extend Model
      base.extend Hooks
    end

  end
end

# EOF