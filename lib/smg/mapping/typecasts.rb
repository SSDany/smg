require 'uri'

module SMG #:nodoc:
  class Mapping #:nodoc:
    module TypeCasts

      class << self
        attr_accessor :typecasts
        def [](key,value)
          return typecasts[key][value] if typecasts.key?(key)
          raise ArgumentError, "Can't typecast to #{key.inspect}"
        end
      end

      self.typecasts = {}
      self.typecasts[ :string   ] = lambda{ |v| v.to_s }
      self.typecasts[ :integer  ] = lambda{ |v| v.to_i }
      self.typecasts[ :boolean  ] = lambda{ |v| v.to_s.strip != 'false' }
      self.typecasts[ :symbol   ] = lambda{ |v| v.to_sym }
      self.typecasts[ :uri      ] = lambda{ |v| ::URI.parse(v.to_s) }

    end
  end
end

# EOF