module SMG #:nodoc:
  class Mapping

    attr_reader :elements, :nested, :attributes
    attr_reader :root
    attr_reader :parsed

    def initialize
      @elements   = {}
      @nested     = {}
      @attributes = {}
    end

    def attach_element(tag,options)
      chain = handle_path(tag)
      thing = Element.new(chain, options)
      if options.key?(:at)
        @attributes[chain] ||= {}
        @attributes[chain][thing.at] = thing
      else
        @elements[chain] = thing
      end
      thing
    end

    def attach_nested(tag,options)
      chain = handle_path(tag)
      thing = Element.new(chain, options.merge(:nested => true))
      @nested[chain] = thing
      thing
    end

    def use_root(path)
      @root = normalize_path(path)
    end

    private

    def normalize_path(path)
      path = path.to_s.squeeze("/")
      path = path[0..-2] if path[-1] == ?/
      path = path[1..-1] if path[0] == ?/
      path.split("/")
    end

    def handle_path(path)
      ret = normalize_path(path)
      ret.unshift(@root) if @root
      ret.flatten!
      ret
    end

  end
end

# EOF