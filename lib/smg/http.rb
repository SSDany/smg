require 'smg/http/request'
require 'smg/http/exceptions'

module SMG #:nodoc:
  module HTTP

    module Model
    end

    def self.append_features(base)
      base.extend Model
    end

  end
end

# EOF