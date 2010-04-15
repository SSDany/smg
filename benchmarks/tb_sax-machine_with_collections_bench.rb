require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

begin

  require 'sax-machine'

  TIMES = ARGV[0] ? ARGV[0].to_i : 1000

  data = File.read(ROOT.join('spec/fixtures/discogs/Genosha+Recordings.xml'))

  class SMGRelease
    include SMG::Resource
    extract 'release/title'
    extract 'release/catno'
    extract 'release/artist'
  end

  class SMGLabel
    include SMG::Resource
    root 'resp/label'
    extract 'name'
    collect 'releases/release'  , :as => :releases, :class => SMGRelease
  end

  class SMARelease
    include SAXMachine
    element   :title
    element   :catno
    element   :artist
  end

  class SMALabel
    include SAXMachine
    element   :name
    elements  :release, :as => :releases, :class => SMARelease
  end

  RBench.run(TIMES) do

    format :width => 85

    column :times
    column :one   , :title => "SAXMachine"
    column :two   , :title => "SMG"
    column :diff  , :title => '#2/#1', :compare => [:two, :one]

    report "parse a tiny collection" do
      one { SMALabel.parse(data)    }
      two { SMGLabel.parse(data)    }
    end

  end

  #p SMGLabel.parse(data)
  #p SMALabel.parse(data)

rescue LoadError
  $stderr << "You should have sax-machine installed in order to run this benchmark.\n" \
             "Try $gem in sax-machine\n" \
             "or take a look at http://github.com/pauldix/sax-machine\n"
end
