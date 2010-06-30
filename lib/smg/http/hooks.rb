module SMG #:nodoc:
  module HTTP #:nodoc:
    module Hooks

      def before_request(options = {}, &block)
        callback(:before_request, options, &block)
      end

      def after_request(options = {}, &block)
        callback(:after_request, options, &block)
      end

      private

      def run_callbacks(kind, *args)
        options = Hash === args.last ? args.pop : {}
        callbacks(kind).each do |callback, conditions|
          next unless conditions.all? { |k,v| Array === v ? v.include?(options[k]) : options[k] == v }
          callback[*args]
        end
      end

      def callback(kind, options = {}, &block)
        raise ArgumentError, "Block not given" unless block_given?
        conditions = {}
        if options.key?(:only)
          conditions[:verb] = Array(options[:only]) & HTTP::VERBS.keys
        elsif options.key?(:except)
          conditions[:verb] = HTTP::VERBS.keys - Array(options[:except])
        end
        callbacks(kind) << [block, conditions]
      end

      def callbacks(kind)
        @callbacks ||= {}
        @callbacks[kind] ||= []
      end

    end
  end
end

# EOF