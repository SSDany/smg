require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Label

  class Release

    include SMG::Resource

    extract :release  , :at => :id, :as => :discogs_id, :class => :integer
    extract :release  , :at => :status

    root 'release'
    extract :title
    extract :catno
    extract :artist

  end

  include SMG::Resource

  root 'resp/label'
  extract :name
  extract :profile
  collect 'releases/release'  , :as => :releases, :class => Release

end

data = File.read(ROOT.join('spec/fixtures/discogs/Genosha+Recordings.xml'))
label = Label.parse(data)

puts label.name
puts label.profile
puts label.releases.map { |release| "#{release.catno}: #{release.title}" }.join("\n")

# EOF