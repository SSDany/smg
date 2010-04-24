require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

begin

  require 'sax-machine'

  TIMES = ARGV[0] ? ARGV[0].to_i : 1000

  data = File.read(ROOT.join('spec/fixtures/twitter/pipopolam.xml'))

  class SMGUser
    include SMG::Resource
    root :user
    extract :id
    extract :location
    extract :created_at
    extract :name
    extract :screen_name
    extract :friends_count
    extract :lang
    extract :profile_image_url
    extract :time_zone
  end

  class SMGStatus
    include SMG::Resource
    root :status
    extract :text
    extract :id
    extract :created_at
    extract :truncated
  end

  class SMAUser
    include SAXMachine
    element :id
    element :location
    element :created_at
    element :name
    element :screen_name
    element :friends_count
    element :lang
    element :profile_image_url
    element :time_zone
  end

  class SMAStatus
    include SAXMachine
    element :text
    element :id
    element :created_at
    element :truncated
  end

  RBench.run(TIMES) do

    format :width => 85

    column :times
    column :one   , :title => "SAXMachine"
    column :two   , :title => "SMG"
    column :diff  , :title => '#2/#1', :compare => [:two, :one]

    report "just give me some characters" do
      one { SMAUser.parse(data) }
      two { SMGUser.parse(data) }
    end

    report "and one nested resource, please" do

      SMAUser.element :status, :class => SMAStatus
      SMGUser.extract :status, :class => SMGStatus

      one { SMAUser.parse(data) }
      two { SMGUser.parse(data) }
    end

  end

  # p SMAUser.parse(data)
  # p SMGUser.parse(data)

rescue LoadError
  $stderr << "You should have sax-machine installed in order to run this benchmark.\n" \
             "Try $gem in sax-machine\n" \
             "or take a look at http://github.com/pauldix/sax-machine\n"
end

# EOF