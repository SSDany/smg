GEMSPEC = Gem::Specification.new do |s|

  s.name = 'smg'
  s.version = '0.2.1'
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
    "lib/smg/http/request.rb",
    "lib/smg/http.rb",
    "lib/smg/mapping/element.rb",
    "lib/smg/mapping/typecasts.rb",
    "lib/smg/mapping.rb",
    "lib/smg/model.rb",
    "lib/smg/resource.rb",
    "lib/smg/version.rb",
    "lib/smg.rb",
    "examples/crazy.rb",
    "examples/discogs/label.rb",
    "examples/discogs/search.rb",
    "examples/helper.rb",
    "examples/plant.rb",
    "examples/twitter.rb",
    "examples/weather.rb",
    "spec/collect_spec.rb",
    "spec/context_spec.rb",
    "spec/extract_spec.rb",
    "spec/filtering_spec.rb",
    "spec/fixtures/discogs/948224.xml",
    "spec/fixtures/discogs/Enzyme+Records.xml",
    "spec/fixtures/discogs/Genosha+Recordings.xml",
    "spec/fixtures/discogs/Ophidian.xml",
    "spec/fixtures/fake/malus.xml",
    "spec/fixtures/fake/valve.xml",
    "spec/fixtures/twitter/pipopolam.xml",
    "spec/fixtures/yahoo.weather.com.xml",
    "spec/http/request_spec.rb",
    "spec/http/shared/automatic.rb",
    "spec/http/shared/non_automatic.rb",
    "spec/http/shared/redirectable.rb",
    "spec/http_spec.rb",
    "spec/lib/helpers/http_helpers.rb",
    "spec/lib/matchers/instance_methods.rb",
    "spec/mapping/element_spec.rb",
    "spec/mapping/typecasts_spec.rb",
    "spec/resource_spec.rb",
    "spec/root_spec.rb",
    "spec/spec_helper.rb"
  ]

  s.add_dependency 'nokogiri', '>=1.3'
  s.add_dependency 'addressable', '>=2.1.1'
  s.rubyforge_project = 'smg'
end

# EOF