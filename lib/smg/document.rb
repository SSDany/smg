module SMG #:nodoc:
  class Document < ::Nokogiri::XML::SAX::Document

    attr_reader :object, :thing

    def initialize(object, thing = nil)
      @object   = object
      @mapping  = object.class.mapping
      @stack    = []
      @docs     = []
      @thing    = thing
      @chars    = ""
    end

    def start_element(name, attrs = [])

      @stack << name

      if doc = @docs.last
        doc.start_element(name, attrs)
      elsif thing = @mapping.nested[@stack]
        @docs << doc = Document.new(thing.data_class.new,thing)
        doc.start_element(name, attrs)
      end

      if !attrs.empty? && maps = @mapping.attributes[@stack]
        attrh = Hash[*attrs]
        maps.values_at(*attrh.keys).compact.each do |m|
          @object.__send__(m.accessor, m.cast(attrh[m.at]))
        end
      end

      @element = @mapping.elements[@stack]
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