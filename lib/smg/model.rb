module SMG #:nodoc:
  module Model

    def extract(tag, options = {})

      thing = if options[:class]
        options.delete(:collection)
        mapping.attach_nested(tag,options)
      else
        mapping.attach_element(tag,options)
      end

      attr_reader thing.name unless instance_methods.include?(thing.name)
      attr_writer thing.name unless instance_methods.include?(thing.accessor)

    end

    def collect(tag, options = {})

      options.merge!(:collection => true)
      thing = options[:class] ? mapping.attach_nested(tag,options) : mapping.attach_element(tag,options)

      unless instance_methods.include?(thing.accessor)
        class_eval <<-CODE
        def #{thing.accessor}(value)
          @#{thing.name} ||= []
          @#{thing.name} << value
        end
        CODE
      end

      unless instance_methods.include?(thing.name)
        class_eval <<-CODE
        def #{thing.name}
          @#{thing.name} ||= []
        end
        CODE
      end

    end

    def root(tag)
      mapping.use_root(tag)
    end

    def parse(xml)
      self.new.parse(xml)
    end

    def mapping
      @mapping ||= Mapping.new
    end

  end
end

# EOF