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
      handle_options(options)
      if options.key?(:at)
        thing = Element.new(chain, options)
        options[:context].each do |context|
          @attributes[context] ||= {}
          @attributes[context][chain] ||= {}
          @attributes[context][chain][thing.at] = thing
        end
      else
        thing = Element.new(chain, options)
        options[:context].each do |context|
          @elements[context] ||= {}
          @elements[context][chain] = thing
        end
      end
      thing
    end

    def attach_nested(tag,options)
      handle_options(options)
      chain = handle_path(tag)
      thing = Element.new(chain, options.merge(:nested => true))
      options[:context].each do |context|
        @nested[context] ||= {}
        @nested[context][chain] = thing
      end
      thing
    end

    def use_root(path)
      @root = normalize_path(path) # just a root tag for further definitions
    end

    private

    def normalize_path(path)
      path.to_s.split("/")
    end

    def handle_options(options)
      options[:context] ||= []
      options[:context] << :default
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