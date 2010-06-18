require 'uri'
require 'time'
require 'date'

module SMG #:nodoc:
  class Mapping #:nodoc:
    module TypeCasts

      class << self
        attr_accessor :typecasts

        def [](key,value)
          return typecasts[key][value] if typecasts.key?(key)
          raise ArgumentError, "Can't typecast #{value.class} into #{key.inspect}"
        end

        def key?(key)
          typecasts.key?(key)
        end

      end

      # same as in extlib
      self.typecasts = {}
      self.typecasts[ :string   ] = lambda{ |v| v.to_s }
      self.typecasts[ :integer  ] = lambda{ |v| v.to_i }
      self.typecasts[ :float    ] = lambda{ |v| v.to_f }
      self.typecasts[ :boolean  ] = lambda{ |v| v.nil? ? nil : (v.to_s.strip != 'false') }
      self.typecasts[ :symbol   ] = lambda{ |v| v.to_sym }
      self.typecasts[ :datetime ] = lambda{ |v| Time.parse(v).utc }
      self.typecasts[ :date     ] = lambda{ |v| Date.parse(v) }
      self.typecasts[ :uri      ] = lambda{ |v| ::URI.parse(v.to_s) }

    end
  end
end

# EOF