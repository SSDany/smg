require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

begin

  require 'happymapper'

  TIMES = ARGV[0] ? ARGV[0].to_i : 1000

  data = File.read(ROOT.join('spec/fixtures/twitter/pipopolam.xml'))

  class SMGUser
    include SMG::Resource
    root 'user'
    extract :id                 , :class => :integer
    extract :created_at         , :class => :datetime
    extract :friends_count      , :class => :integer
    extract :location
    extract :name
    extract :screen_name
    extract :lang
    extract :profile_image_url
    extract :time_zone
  end

  class SMGStatus
    include SMG::Resource
    root 'status'
    extract :text
    extract :id                 , :class => :integer
    extract :created_at         , :class => :datetime
    extract :truncated
  end

  class User
    include HappyMapper
    element :id                 , Integer
    element :location           , String
    element :created_at         , Time
    element :name               , String
    element :screen_name        , String
    element :friends_count      , Integer
    element :lang               , String
    element :profile_image_url  , String
    element :time_zone          , String
  end

  class Status
    include HappyMapper
    element :text           , String
    element :id             , Integer
    element :created_at     , Time
    element :truncated      , String
  end

  RBench.run(TIMES) do

    format :width => 85

    column :times
    column :one   , :title => "HappyMapper"
    column :two   , :title => "SMG"
    column :diff  , :title => '#2/#1', :compare => [:two, :one]

    report "just give me some characters" do
      one { User.parse(data)    }
      two { SMGUser.parse(data) }
    end

    report "and one nested resource, please" do

      User.has_one :status, Status
      SMGUser.extract :status, :class => SMGStatus

      one { User.parse(data)    }
      two { SMGUser.parse(data) }
    end

  end

  # p User.parse(data)
  # p SMGUser.parse(data)

  # Just note, that happymapper is *another* declarative
  # parser, not SAX-based, and it may be the best solution
  # if your model is tiny.

rescue LoadError
  $stderr << "You should have happymapper installed in order to run this benchmark.\n" \
             "Try $gem in happymapper\n" \
             "or take a look at http://github.com/jnunemaker/happymapper\n"
end

# EOF