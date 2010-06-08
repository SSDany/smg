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

      @mapping.refresh!
    end

    def start_element(name, attrs)

      @stack << name
      ahash = nil

      if doc = @docs.last
        doc.start_element(name, attrs)
      elsif (thing = @mapping.nested[@stack]) &&
          !@mapping.parsed.include?(thing.object_id) &&
          thing.in_context_of?(@context) &&
          thing.with?(ahash ||= Hash[*attrs])

        @docs << doc = Document.new(thing.data_class.new,@context,thing)
        doc.start_element(name, attrs)
      end

      if !attrs.empty? && maps = @mapping.attributes[@stack]
        maps.values_at(*(ahash ||= Hash[*attrs]).keys).compact.each do |m|
          if !@mapping.parsed.include?(m.object_id) &&
            m.in_context_of?(@context) &&
            m.with?(ahash)

            @object.__send__(m.accessor, m.cast(ahash[m.at]))
            @mapping.parsed << m.object_id unless m.collection?
          end
        end
      end

      if (e = @mapping.elements[@stack]) &&
          !@mapping.parsed.include?(e.object_id) &&
          e.in_context_of?(@context) &&
          e.with?(ahash ||= Hash[*attrs])
        @element = e
        @chars = ""
      end

    end

    def end_element(name)

      if @element
        @object.__send__(@element.accessor, @element.cast(@chars))
        @mapping.parsed << @element.object_id unless @element.collection?
        @chars = ""
        @element = nil
      end

      if doc = @docs.last
        doc.end_element(name)
        if (t = doc.thing).path == @stack
          @object.__send__(t.accessor, doc.object)
          @docs.pop
          @mapping.parsed << t.object_id unless t.collection?
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