require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

begin

  require 'happymapper'

  TIMES = ARGV[0] ? ARGV[0].to_i : 1000

  data = File.read(ROOT.join('spec/fixtures/discogs/Genosha+Recordings.xml'))

  class SMGRelease
    include SMG::Resource
    extract 'release'           , :at => :id
    extract 'release'           , :at => :status
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

  class HMARelease
    include HappyMapper
    tag 'release'
    attribute :id     , Integer
    attribute :status , String
    element   :title  , String
    element   :catno  , String
    element   :artist , String
  end

  class HMALabel
    include HappyMapper
    tag 'resp'
    element :name       , String      , :tag => 'label/name'
    has_many :releases  , HMARelease  , :tag => 'label/releases'
  end

  RBench.run(TIMES) do

    format :width => 85

    column :times
    column :one   , :title => "HappyMapper"
    column :two   , :title => "SMG"
    column :diff  , :title => '#2/#1', :compare => [:two, :one]

    report "parse a tiny collection" do
      one { HMALabel.parse(data)    }
      two { SMGLabel.parse(data)    }
    end

  end

  # p SMGLabel.parse(data)
  # p HMALabel.parse(data)

rescue LoadError
  $stderr << "You should have happymapper installed in order to run this benchmark.\n" \
             "Try $gem in happymapper\n" \
             "or take a look at http://github.com/jnunemaker/happymapper\n"
end
