module SMG #:nodoc:
  class Mapping

    attr_reader :elements, :nested, :attributes
    attr_reader :root

    def initialize
      @elements   = {}
      @nested     = {}
      @attributes = {}
    end

    def attach_element(tag,options)
      chain = handle_path(tag)
      if options.key?(:at)
        thing = Element.new(chain, options)
        @attributes[chain] ||= {}
        @attributes[chain][thing.at] = thing
      else
        @elements[chain] = Element.new(chain, options)
      end
    end

    def attach_nested(tag,options)
      chain = handle_path(tag)
      @nested[chain] = Element.new(chain, options.merge(:nested => true))
    end

    def use_root(path)
      @root = normalize_path(path) # just a root tag for further definitions
    end

    private

    def normalize_path(path)
      path.to_s.split("/")
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