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

      private

      def uri_for(path, query = {})
        ret = Addressable::URI.parse(@site)
        ret.path = path
        qvalues = {}
        qvalues.update(@params) if @params
        qvalues.update(query)
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