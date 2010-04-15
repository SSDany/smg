module Spec #:nodoc:
  module Matchers #:nodoc:

    #http://github.com/rubyspec/mspec/blob/master/lib/mspec/matchers/have_instance_method.rb
    class HaveInstanceMethodMatcher

      def initialize(method, include_super)
        @method = method.to_sym
        @include_super = include_super
      end

      def matches?(mod)
        @mod = mod
        mod.instance_methods(@include_super).include?(@method) || 
        mod.instance_methods(@include_super).include?(@method.to_s)
      end

      def failure_message
        ["Expected #{@mod} to have instance method '#{@method.to_s}'",
         "but it does not"]
      end

      def negative_failure_message
        ["Expected #{@mod} NOT to have instance method '#{@method.to_s}'",
         "but it does"]
      end
    end

    module HaveInstanceMethodMixin
      def have_instance_method(method, include_super=true)
        HaveInstanceMethodMatcher.new method, include_super
      end
    end

  end
end

# EOF