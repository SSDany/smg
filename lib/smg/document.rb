module SMG #:nodoc:
  class Document < ::Nokogiri::XML::SAX::Document

    attr_reader :object, :thing

    def initialize(object, context = :default, thing = nil)
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

      if doc = @docs.last
        doc.start_element(name, attrs)
      elsif @mapping.nested.key?(@context) && thing = @mapping.nested[@context][@stack]
        @docs << doc = Document.new(thing.data_class.new,@context,thing)
        doc.start_element(name, attrs)
      end

      if !attrs.empty? && @mapping.attributes.key?(@context) && maps = @mapping.attributes[@context][@stack]
        maps.values_at(*Hash[*attrs].keys).compact.each do |m|
          ix = attrs.index(m.at)
          @object.__send__(m.accessor, m.cast(attrs.at(ix+=1))) if ix
        end
      end

      @element = @mapping.elements.key?(@context) ? @mapping.elements[@context][@stack] : nil
      @chars = ""

    end

    def end_element(name)
      @object.send(@element.accessor, @element.cast(@chars)) if @element && @chars
      @chars, @element = nil, nil
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
        @chars ||= ""
        @chars << string
      elsif @element
        @chars << string
      end
    end

  end
end

# EOF