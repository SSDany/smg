module SMG #:nodoc:
  class Mapping #:nodoc:

    class Element
      attr_reader :path, :name, :accessor, :data_class, :cast_to, :at

      def initialize(path, options = {})

        @name       = (options[:as] || options[:at] || path.last).to_sym
        @path       = path
        @collection = !!options[:collection]
        @accessor   = @collection ? :"attach_#{@name}" : :"#{@name}="
        @data_class = nil
        @cast_to    = nil

        if c = options[:class]
          if Class === c
            raise ArgumentError, "#{c} is not an SMG::Model" unless c.include?(::SMG::Resource)
            @data_class = c
          elsif Symbol === c
            raise ArgumentError, "#{c} is not a valid typecast" unless TypeCasts.key?(c)
            @cast_to = c
          else
            raise ArgumentError, ":class should be an SMG::Model or a Symbol"
          end
        end

        #ignore :at on nested collections of resources
        @at = options.key?(:at) && !@data_class ? options[:at].to_s : nil

      end

      def cast(value)
        return value unless @cast_to
        ::SMG::Mapping::TypeCasts[@cast_to, value]
      rescue
        #TODO: report about malformed data
      end

      def collection?
        @collection
      end

    end

  end
end

# EOF