module SMG #:nodoc:
  class Mapping #:nodoc:

    class Element
      attr_reader :path, :name, :accessor, :data_class, :cast_to, :at

      def initialize(path, options = {})

        @name       = (options[:as] || options[:at] || path.last).to_sym
        @path       = path
        @collection = !!options[:collection]
        @accessor   = @collection ? :"append_to_#{@name}" : :"#{@name}="
        @data_class = nil
        @cast_to    = nil
        @context    = options[:context] || [] #TODO: validations

        if klass = options[:class]
          if Class === klass
            raise ArgumentError, "#{klass} is not an SMG::Model" unless klass.include?(::SMG::Resource)
            @data_class = klass
          elsif Symbol === klass
            raise ArgumentError, "#{klass} is not a valid typecast" unless TypeCasts.key?(klass)
            @cast_to = klass
          else
            raise ArgumentError, ":class should be an SMG::Model or a Symbol"
          end
        end

        #ignore :at on nested collections of resources
        @at = options.key?(:at) && !@data_class ? options[:at].to_s : nil

      end

      def cast(value)
        @cast_to ? ::SMG::Mapping::TypeCasts[@cast_to, value] : value
      rescue
        raise ArgumentError, "#{value.inspect} is not a valid source for #{@cast_to.inspect}"
      end

      def collection?
        @collection
      end

      def in_context_of?(context)
        @context.empty? || @context.include?(context)
      end

    end

  end
end

# EOF