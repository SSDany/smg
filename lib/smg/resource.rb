module SMG #:nodoc:
  module Resource

    def self.included(base)
      base.extend Model
    end

    def parsed?
      @_parsed ||= false
    end

    def parsed!
      @_parsed = true
    end

  end
end

# EOF