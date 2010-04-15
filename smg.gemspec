GEMSPEC = Gem::Specification.new do |s|

  s.name = 'smg'
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = %w(README.rdoc)
  s.description = <<-EOF
Simple declaratibve XML parsing library. Backed by Nokogiri
  EOF
  s.summary = 'Simple declaratibve XML parsing library. Backed by Nokogiri'
  s.description = s.summary
  s.authors = %w[SSDany]
  s.email = 'inadsence@gmail.com'
  s.require_path = 'lib'
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