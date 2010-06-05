module SMG #:nodoc:
  class Mapping #:nodoc:

    class Element
      attr_reader :path, :name, :accessor, :data_class, :cast_to, :at, :context, :with

      def initialize(path, options = {})

        @name       = (options[:as] || options[:at] || path.last).to_sym
        @path       = path
        @collection = !!options[:collection]
        @with       = options[:with] ? options[:with].to_hash : nil
        @accessor   = @collection ? :"append_to_#{@name}" : :"#{@name}="
        @data_class = nil
        @cast_to    = nil
        @context    = nil

        if options.key?(:context)
          if Array === options[:context]
            @context = options[:context].compact
            @context.uniq!
            @context = nil if @context.empty?
          else
            raise ArgumentError, ":context should be an Array"
          end
        end

        if options.key?(:class)
          klass = options[:class]
          if SMG::Model === klass
            @data_class = klass
          elsif SMG::Mapping::TypeCasts.key?(klass)
            @cast_to = klass
          else
            raise ArgumentError, ":class should be an SMG::Model or a valid typecast"
          end
        end

        #ignore :at on nested collections of resources
        @at = options.key?(:at) && !@data_class ? options[:at].to_s : nil

      end

      def cast(value)
        @cast_to ? SMG::Mapping::TypeCasts[@cast_to, value] : value
      rescue
        raise ArgumentError, "#{value.inspect} is not a valid source for #{@cast_to.inspect}"
      end

      def collection?
        @collection
      end

      def in_context_of?(context)
        @context.nil? || @context.include?(context)
      end

      def with?(attrh)
        @with.each { |k,v| return false unless attrh[k] == v } if @with # attrh.include?(k) && attrh[k] == v
        true
      end

    end

  end
end

# EOF