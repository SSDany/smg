module SMG #:nodoc:
  module Resource

    def self.included(base)
      base.extend Model
    end

    def parse(data)
      doc = SMG::Document.new(self)
      ::Nokogiri::XML::SAX::Parser.new(doc).parse(data)
      self
    end

  end
end

# EOF