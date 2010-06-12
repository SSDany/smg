require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

module Discogs
  class Label

    class Release

      include SMG::Resource

      extract 'release' , :at => :id, :as => :discogs_id, :class => :integer
      extract 'release' , :at => :status

      extract 'release/title'
      extract 'release/catno'
      extract 'release/artist'
      extract 'release/format'

    end

    include SMG::Resource

    root 'resp/label'

    extract 'name'
    extract 'contactinfo'       , :as => :contacts
    extract 'profile'
    extract 'parentLabel'       , :as => :parent
    collect 'urls/url'          , :as => :links
    collect 'sublabels/label'   , :as => :sublabels
    collect 'releases/release'  , :as => :releases, :class => Release , :context => [:releases], :with => {"status" => "Accepted"}

    def name_with_parent
      "#{name}#{" @ #{parent}" if parent}"
    end

  end
end

data = File.read(ROOT.join('spec/fixtures/discogs/Enzyme+Records.xml'))

template = <<-TEMPLATE
<%= label.name_with_parent %>

%label.sublabels.each do |sublabel|
  * <%= sublabel %>
%end

%label.releases.each do |release|
  * [<%= release.catno %>] <%= release.artist %> - <%= release.title %>
%end

TEMPLATE

require 'erb'

label = Discogs::Label.parse(data,:releases)
$stdout << ERB.new(template, nil, "%").result(binding)

label = Discogs::Label.parse(data)
$stdout << ERB.new(template, nil, "%").result(binding)

# EOF