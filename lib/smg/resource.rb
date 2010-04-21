module SMG #:nodoc:
  module Resource

    def self.included(base)
      base.extend Model
    end

    def parsed?
      @_parsed
    end

  end
end

# EOF