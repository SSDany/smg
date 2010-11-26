GEMSPEC = Gem::Specification.new do |s|

  s.name = 'smg'
  s.version = '0.2.3'
  s.platform = Gem::Platform::RUBY

  s.authors = %w[SSDany]
  s.email = 'inadsence@gmail.com'
  s.homepage = 'http://github.com/SSDany/smg'
  s.summary = 'Simple declaratibve XML parsing library. Backed by Nokogiri'
  s.description = <<-DESCR
XML to Object mapping library with simple declarative syntax.
Supports 'contextual' parsing and conditions.
Provides a simple HTTP interaction solution.
DESCR

  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = %w(README.rdoc)
  s.files = s.extra_rdoc_files + [
    "lib/smg/document.rb",
    "lib/smg/http/exceptions.rb",
    "lib/smg/http/hooks.rb",
    "lib/smg/http/request.rb",
    "lib/smg/http.rb",
    "lib/smg/mapping/element.rb",
    "lib/smg/mapping/typecasts.rb",
    "lib/smg/mapping.rb",
    "lib/smg/model.rb",
    "lib/smg/resource.rb",
    "lib/smg/version.rb",
    "lib/smg.rb",
  ]

  s.add_dependency 'nokogiri', '>=1.3'
  s.add_dependency 'addressable', '>=2.1.2'
  s.add_development_dependency "rspec", ">= 1.2.0"
  s.rubyforge_project = 'smg'
end

# EOF