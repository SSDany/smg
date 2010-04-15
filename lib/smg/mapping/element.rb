module SMG #:nodoc:
  class Mapping #:nodoc:

    class Element
      attr_reader :path, :name, :accessor, :data_class, :at

      def initialize(path, options = {})
        @name       = (options[:as] || options[:at] || path.last).to_s
        @path       = path
        @collection = !!options[:collection]
        @accessor   = @collection ? "attach_#{@name}" : "#{@name}="
        @data_class = options[:class]
        @at         = options.key?(:at) && !@data_class ? options[:at].to_s : nil
      end

      def collection?
        @collection
      end

    end

  end
end

# EOF