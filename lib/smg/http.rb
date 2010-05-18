require 'smg/http/request'
require 'smg/http/exceptions'

module SMG #:nodoc:
  module HTTP

    module Model

      def site(value)
        @site = value
      end

      def params(value)
        @params = value
      end

      def get(path, options = {}, &block)
        http Net::HTTP::Get, path, options, &block
      end

      def head(path, options = {}, &block)
        http Net::HTTP::Head, path, options, &block
      end

      def delete(path, options = {}, &block)
        http Net::HTTP::Delete, path, options, &block
      end

      def post(path, options = {}, &block)
        http Net::HTTP::Post, path, options, &block
      end

      def put(path, options = {}, &block)
        http Net::HTTP::Put, path, options, &block
      end

      private

      def http(verb, path, options = {})
        raise "site URI missed" unless @site
        opts = options.dup
        uri = uri_for(path, opts.delete(:query))
        response = SMG::HTTP::Request.new(verb, uri, opts).perform
        parse block_given? ? yield(response) : response.body
      end

      def uri_for(path, query = nil)
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
    end

  end
end

# EOF