module SMG #:nodoc:
  class Document < ::Nokogiri::XML::SAX::Document

    attr_reader :object, :thing

    def initialize(object, context = nil, thing = nil)
      @object   = object
      @mapping  = object.class.mapping
      @stack    = []
      @docs     = []
      @thing    = thing
      @context  = context
      @chars    = ""
    end

    def start_element(name, attrs = [])

      @stack << name
      ahash = nil

      if doc = @docs.last
        doc.start_element(name, attrs)
      elsif (thing = @mapping.nested[@stack]) &&
          thing.in_context_of?(@context) &&
          thing.with?(ahash ||= Hash[*attrs])

        @docs << doc = Document.new(thing.data_class.new,@context,thing)
        doc.start_element(name, attrs)
      end

      if !attrs.empty? && maps = @mapping.attributes[@stack]
        maps.values_at(*(ahash ||= Hash[*attrs]).keys).compact.each do |m|
          @object.__send__(m.accessor, m.cast(ahash[m.at])) if
            m.in_context_of?(@context) &&
            m.with?(ahash)
        end
      end

      if (e = @mapping.elements[@stack]) &&
          e.in_context_of?(@context) &&
          e.with?(ahash ||= Hash[*attrs])

        @element = e
        @chars = ""
      end

    end

    def end_element(name)

      if @element
        @object.__send__(@element.accessor, @element.cast(@chars))
        @chars = ""
        @element = nil
      end

      if doc = @docs.last
        doc.end_element(name)
        if doc.thing.path == @stack
          @object.__send__(doc.thing.accessor, doc.object)
          @docs.pop
        end
      end

      @stack.pop

    end

    def characters(string)
      if doc = @docs.last
        doc.characters(string)
        @chars << string
      elsif @element
        @chars << string
      end
    end

  end
end

# EOF