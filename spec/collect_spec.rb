# encoding: utf-8

require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')

describe SMG::Model, ".collect" do

  include Spec::Matchers::HaveInstanceMethodMixin

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = data = File.read(FIXTURES_DIR + 'discogs/Genosha+Recordings.xml')
  end

  it "defines appropriate reader and writer" do
    @klass.root 'resp/label'
    @klass.collect 'releases/release/catno', :as => :catalogue_numbers
    @klass.should have_instance_method 'catalogue_numbers'
    @klass.should have_instance_method 'append_to_catalogue_numbers'
  end

  it "never overrides readers" do
    @klass.root 'resp/label'
    @klass.collect 'urls/url', :as => :urls
    @klass.class_eval <<-CODE
    def urls
      unless @urls.nil?
        @urls.map{|u| u.empty? ? nil : u.strip}.compact.join(', ')
      end
    end
    CODE
    label = @klass.parse(@data)
    label.urls.should == 'http://www.genosharecordings.com/, http://www.myspace.com/genosharecordings'
  end

  it "never overrides writers" do
    @klass.root 'resp/label'
    @klass.collect 'urls/url', :as => :urls
    @klass.class_eval <<-CODE
    def append_to_urls(value)
      unless value.nil? || value.empty?
        @urls ||= []
        @urls << URI.parse(value)
      end
    end
    CODE
    label = @klass.parse(@data)
    label.urls.should be_an_instance_of ::Array
    label.urls.should == [
      URI.parse('http://www.genosharecordings.com/'),
      URI.parse('http://www.myspace.com/genosharecordings')
      ]
  end

end

describe SMG::Model, ".collect", "without :class option" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = data = File.read(FIXTURES_DIR + 'discogs/Genosha+Recordings.xml')
  end

  it "collects texts" do
    @klass.root 'resp/label'
    @klass.collect 'releases/release/catno', :as => :catalogue_numbers
    label = @klass.parse(@data)
    label.catalogue_numbers.should be_an_instance_of ::Array
    label.catalogue_numbers.should == ["GEN 001", "GEN 001", "GEN 002", "GEN 003", "GEN 006", "GEN 008", "GEN 008", "GEN 009", "GEN 012", "GEN 013", "GEN 015", "GEN004", "GEN005", "GEN006½", "GEN007", "GEN009", "GEN010", "GEN011", "GEN012", "GEN014", "GEN016", "GEN017", "GENCD01", "GENOSHA 018"]
  end

  it "collects attributes" do
    @klass.root 'resp/label'
    @klass.collect 'releases/release', :at => :id     , :as => :release_ids
    @klass.collect 'releases/release', :at => :status , :as => :release_statuses
    label = @klass.parse(@data)
    label.release_ids.should be_an_instance_of ::Array
    label.release_statuses.should be_an_instance_of ::Array
    label.release_ids.should == ["183713", "1099277", "183735", "225253", "354681", "1079143", "448035", "1083336", "1079145", "814757", "964449", "254166", "341855", "387611", "396345", "448709", "529057", "662611", "683859", "915651", "1021944", "1494949", "354683", "1825580"] 
    label.release_statuses.should == ["Accepted"]*24
  end

  it "is able to build multiple datasets" do
      custom_xml = <<-XML
<releases>
  <release id="2259548" status="Accepted" type="TrackAppearance">Signal Flow Podcast 03</release>
  <release id="2283715" status="Accepted" type="TrackAppearance">United Hardcore Forces</release>
  <release id="2283652" status="Accepted" type="TrackAppearance">Warp Madness</release>
  <release id="1775742" status="Accepted" type="UnofficialRelease">Stalker 2.9 Level 3 Compilation</release>
</release>
XML

    @klass.collect 'releases/release', :at => :id, :as => :ids
    @klass.collect 'releases/release', :at => :type, :as => :types
    @klass.collect 'releases/release', :as => :titles

    collection = @klass.parse(custom_xml)
    collection.ids.should     == ["2259548", "2283715", "2283652", "1775742"]
    collection.types.should   == ["TrackAppearance", "TrackAppearance", "TrackAppearance", "UnofficialRelease"]
    collection.titles.should  == ["Signal Flow Podcast 03", "United Hardcore Forces", "Warp Madness", "Stalker 2.9 Level 3 Compilation"]
  end

  it "collects nothing when there's no matching elements" do
    @klass.root 'resp/label'
    @klass.collect 'releases/release', :at => :bogus, :as => :release_ids
    label = @klass.parse(@data)
    label.release_ids.should be_an_instance_of ::Array
    label.release_ids.should be_empty
  end

end

describe SMG::Model, ".collect", "when :class option represents SMG::Resource" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = data = File.read(FIXTURES_DIR + 'discogs/Genosha+Recordings.xml')
  end

  before :each do
    @release_class = Class.new { include SMG::Resource }
    @release_class.extract 'release'       , :at => :id      , :as => :discogs_id
    @release_class.extract 'release'       , :at => :status
    @release_class.extract 'release/title'

    @image_class = Class.new { include SMG::Resource }
    @image_class.extract 'image', :at => :uri
    @image_class.extract 'image', :at => :uri150, :as => :preview
    @image_class.extract 'image', :at => :width
    @image_class.extract 'image', :at => :height
  end

  it "collects resources" do
    @klass.root 'resp/label'
    @klass.collect 'releases/release', :as => :releases, :class => @release_class
    label = @klass.parse(@data)
    label.releases.should be_an_instance_of ::Array
    label.releases.size.should == 24
    label.releases[8].title.should == "No, We Don't Want You To Clap Your Fucking Hands"
    label.releases[8].discogs_id.should == "1079145"
    label.releases[8].status.should == "Accepted"
  end

  it "is able to build multiple collections" do
    @klass.root 'resp/label'
    @klass.collect 'releases/release' , :as => :releases    , :class => @release_class
    @klass.collect 'images/image'     , :as => :images      , :class => @image_class
    @klass.collect 'releases/release' , :as => :release_ids , :at => :id
    label = @klass.parse(@data)

    label.releases.should be_an_instance_of ::Array
    label.releases.size.should == 24
    label.releases[8].should be_an_instance_of @release_class
    label.releases[8].title.should == "No, We Don't Want You To Clap Your Fucking Hands"
    label.releases[8].discogs_id.should == "1079145"

    label.images.should be_an_instance_of ::Array
    label.images.size.should == 2
    label.images[1].should be_an_instance_of @image_class
    label.images[1].width.should == '600'
    label.images[1].height.should == '159'
    label.images[1].uri.should == 'http://www.discogs.com/image/L-16366-1165574398.jpeg'
    label.images[1].preview.should == 'http://www.discogs.com/image/L-150-16366-1165574398.jpeg'

    label.release_ids.should == ["183713", "1099277", "183735", "225253", "354681", "1079143", "448035", "1083336", "1079145", "814757", "964449", "254166", "341855", "387611", "396345", "448709", "529057", "662611", "683859", "915651", "1021944", "1494949", "354683", "1825580"] 
  end

  it "collects nothing when there's no matching elements" do
    @klass.root 'resp/label'
    @klass.collect 'releases/bogus', :as => :releases, :class => @release_class
    label = @klass.parse(@data)
    label.releases.should be_an_instance_of ::Array
    label.releases.should be_empty
  end

end

describe SMG::Model, ".collect", "when :class option represents built-in typecast" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = data = File.read(FIXTURES_DIR + 'discogs/Genosha+Recordings.xml')
  end

  it "makes an attempt to perform a typecast" do
    Class.new { include SMG::Resource }
    @klass.root 'resp/label'
    @klass.collect 'releases/release', :at => :id, :class => :integer, :as => :release_ids
    label = @klass.parse(@data)
    label.release_ids.should == [183713, 1099277, 183735, 225253, 354681, 1079143, 448035, 1083336, 1079145, 814757, 964449, 254166, 341855, 387611, 396345, 448709, 529057, 662611, 683859, 915651, 1021944, 1494949, 354683, 1825580] 
  end

  it "raises an ArgumentError if typecasting fails" do
    Class.new { include SMG::Resource }
    @klass.root 'resp/label'
    @klass.collect 'releases/release', :at => :id, :class => :datetime, :as => :release_ids
    lambda { @klass.parse(@data) }.
    should raise_error ArgumentError, %r{"183713" is not a valid source for :datetime} 
  end

end

describe SMG::Model, ".collect", "with nested collections" do

  before :each do
    @klass = Class.new { include SMG::Resource }
    @data = data = File.read(FIXTURES_DIR + 'discogs/948224.xml')
  end

  before :each do
    @artist_class = Class.new { include SMG::Resource }
    @artist_class.root 'artist'
    @artist_class.extract :name
    @artist_class.extract :role

    @track_class = Class.new { include SMG::Resource }
    @track_class.root 'track'
    @track_class.extract :position
    @track_class.extract :title
    @track_class.extract :duration
    @track_class.collect 'extraartists/artist', :as => :extra_artists, :class => @artist_class
  end

  after :each do
    @release.tracks.should be_an_instance_of ::Array
    @release.tracks.size.should == 6

    track = @release.tracks[1]
    track.position.should == 'A2'
    track.title.should == 'Butterfly V.I.P. (Interlude By Cubist Boy & Tapage)'
    track.duration.should == '1:24'

    track.extra_artists.should be_an_instance_of ::Array
    track.extra_artists.size.should == 2
    track.extra_artists[1].name.should == 'Tapage'
    track.extra_artists[1].role.should == 'Co-producer'
  end

  it "supports nested collections" do
    @klass.root 'resp/release'
    @klass.collect 'tracklist/track', :as => :tracks, :class => @track_class

    @release = @klass.parse(@data)
  end

  it "handles each collection independently" do

    @track_class.collect 'extraartists/artist/name', :as => :extra_artist_names

    @klass.root 'resp/release/tracklist'
    @klass.collect 'track'                      , :as => :tracks, :class => @track_class
    @klass.collect 'track/title'                , :as => :tracklist
    @klass.collect 'track/extraartists/artist'  , :as => :extra_artists, :class => @artist_class

    @release = @klass.parse(@data)

    @release.tracklist.should be_an_instance_of ::Array
    @release.tracklist.size.should == 6
    @release.tracklist.should == ["Butterfly V.I.P. (VIP Edit By Ophidian)", "Butterfly V.I.P. (Interlude By Cubist Boy & Tapage)", "Butterfly V.I.P. (Original Version)", "Hammerhead V.I.P. (VIP Edit By Ophidian)", "Hammerhead V.I.P. (Interlude By Cubist Boy & Tapage)", "Hammerhead V.I.P. (Original Version)"]

    @release.tracks.should be_an_instance_of ::Array
    @release.tracks.size.should == 6

    @release.extra_artists.should be_an_instance_of ::Array
    @release.extra_artists.size.should == 6
    @release.extra_artists[2].name.should == 'Tapage'
    @release.extra_artists[2].role.should == 'Co-producer'

  end

end

# EOF