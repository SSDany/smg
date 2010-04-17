GEMSPEC = Gem::Specification.new do |s|

  s.name = 'smg'
  s.version = '0.0.2'
  s.platform = Gem::Platform::RUBY

  s.authors = %w[SSDany]
  s.email = 'inadsence@gmail.com'
  s.summary = 'Simple declaratibve XML parsing library. Backed by Nokogiri'
  s.description = <<-DESCR
Object to xml mapping library with simple declarative syntax.
Backed by Nokogiri's SAX Parser.
DESCR

  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = %w(README.rdoc)
  s.files = s.extra_rdoc_files + [
    "lib/smg/document.rb",
    "lib/smg/mapping/element.rb",
    "lib/smg/mapping/typecasts.rb",
    "lib/smg/mapping.rb",
    "lib/smg/model.rb",
    "lib/smg/resource.rb",
    "lib/smg/version.rb",
    "lib/smg.rb"
  ]

  s.add_dependency 'nokogiri', '>=1.3'
  s.rubyforge_project = 'smg'
end

# EOF