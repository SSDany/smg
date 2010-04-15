module SMG #:nodoc:
  module Model

    def extract(tag, options = {})

      thing = if Class === options[:class]
        options.delete(:collection)
        mapping.attach_nested(tag,options)
      else
        mapping.attach_element(tag,options)
      end

      attr_reader thing.name if (instance_methods & [thing.name, thing.name.to_s]).empty?
      attr_writer thing.name if (instance_methods & [thing.accessor, thing.accessor.to_s]).empty?

    end

    def collect(tag, options = {})

      options.merge!(:collection => true)
      thing = Class === options[:class] ? mapping.attach_nested(tag,options) : mapping.attach_element(tag,options)

      if (instance_methods & [thing.accessor, thing.accessor.to_s]).empty?
        class_eval <<-CODE
        def #{thing.accessor}(value)
          @#{thing.name} ||= []
          @#{thing.name} << value
        end
        CODE
      end

      if (instance_methods & [thing.name, thing.name.to_s]).empty?
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