module SMG #:nodoc:
  class Document < ::Nokogiri::XML::SAX::Document

    attr_reader :object, :thing

    def initialize(object, context = nil, thing = nil)
      @object   = object
      @mapping  = object.class.mapping
      @stack    = []
      @docs     = []
      @elements = []
      @thing    = thing
      @context  = context
      @parsed   = []
    end

    def start_element(name, attrs)

      @stack << name
      ahash = nil

      if thing = @mapping.nested[@stack] and
         !@parsed.include?(thing.object_id) &&
         thing.in_context_of?(@context) &&
         thing.with?(ahash ||= Hash[*attrs])
        @docs << Document.new(thing.data_class.new,@context,thing)
      end

      @docs.each { |doc| doc.start_element(name,attrs) }

      if !attrs.empty? && maps = @mapping.attributes[@stack]
        #maps.values_at(*(ahash ||= Hash[*attrs]).keys).compact.each do |m|
        maps.values_at(*(ahash ||= Hash[*attrs]).keys).flatten.compact.each do |m|
          if !@parsed.include?(m.object_id) &&
             m.in_context_of?(@context) &&
             m.with?(ahash)
            @object.__send__(m.accessor, m.cast(ahash[m.at]))
            @parsed << m.object_id unless m.collection?
          end
        end
      end

      if e = @mapping.elements[@stack] and
         !@parsed.include?(e.object_id) &&
         e.in_context_of?(@context) &&
         e.with?(ahash ||= Hash[*attrs])
        @elements << [e,""]
      end

    end

    def end_element(name)

      if e = @elements.last and e.first.path == @stack
        e,chars = *@elements.pop
        @object.__send__(e.accessor, e.cast(chars))
        @parsed << e.object_id unless e.collection?
      end

      @docs.each { |doc| doc.end_element(name) }

      if doc = @docs.last and doc.thing.path == @stack
        @object.__send__(doc.thing.accessor, doc.object)
        @parsed << doc.thing.object_id unless doc.thing.collection?
        @docs.pop
      end

      @stack.pop

    end

    def characters(string)
      @docs.each { |doc| doc.characters(string) }
      @elements.each { |e| e.last << string }
    end

    def cdata_block(string)
      characters(string)
    end

  end
end

# EOF