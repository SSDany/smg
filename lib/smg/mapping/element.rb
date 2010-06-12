module SMG #:nodoc:
  class Mapping #:nodoc:

    class Element
      attr_reader :path, :name, :accessor, :data_class, :cast_to, :at, :context, :with

      def initialize(path, options = {})

        @name       = (options[:as] || options[:at] || path.last.gsub(":","_")).to_sym
        @path       = path
        @collection = !!options[:collection]
        @with       = options[:with] ? normalize_conditions(options[:with]) : nil
        @accessor   = @collection ? :"append_to_#{@name}" : :"#{@name}="
        @data_class = nil
        @cast_to    = nil
        @context    = nil

        if options.key?(:context)
          raise ArgumentError, "+options[:context]+ should be an Array of Symbols" unless
            Array === options[:context] &&
            options[:context].all?{ |c| Symbol === c }

          @context = options[:context].compact
          @context.uniq!
          @context = nil if @context.empty?
        end

        if options.key?(:class)
          klass = options[:class]
          if SMG::Model === klass
            @data_class = klass
          elsif SMG::Mapping::TypeCasts.key?(klass)
            @cast_to = klass
          else
            raise ArgumentError, "+options[:class]+ should be an SMG::Model or a valid typecast"
          end
        end

        #ignore options[:at] on nested collections of resources
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
        @with.nil? || @with.all? { |k,v| attrh[k] == v }
      end

      private

      def normalize_conditions(conditions)
        ret = {}
        conditions.each do |k,v|
          v = v.to_s unless v.nil?
          ret[k.to_s] = v
        end
        ret
      end

    end

  end
end

# EOF