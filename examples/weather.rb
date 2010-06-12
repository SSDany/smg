require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class YWeather

  CONDITION_CODES = {
     1 => "tornado",
     2 => "tropical storm",
     3 => "hurricane",
     4 => "severe thunderstorms",
     4 => "thunderstorms",
     5 => "mixed rain and snow",
     6 => "mixed rain and sleet",
     7 => "mixed snow and sleet",
     8 => "freezing drizzle",
     9 => "drizzle",
    10 => "freezing rain",
    11 => "showers",
    12 => "showers",
    13 => "snow flurries",
    14 => "light snow showers",
    15 => "blowing snow",
    16 => "snow",
    17 => "hail",
    18 => "sleet",
    19 => "dust",
    20 => "foggy",
    21 => "haze",
    22 => "smoky",
    23 => "blustery",
    24 => "windy",
    25 => "cold",
    26 => "cloudy",
    27 => "mostly cloudy (night)",
    28 => "mostly cloudy (day)",
    29 => "partly cloudy (night)",
    30 => "partly cloudy (day)",
    31 => "clear (night)",
    32 => "sunny",
    33 => "fair (night)",
    34 => "fair (day)",
    35 => "mixed rain and hail",
    36 => "hot",
    37 => "isolated thunderstorms",
    38 => "scattered thunderstorms",
    39 => "scattered thunderstorms",
    40 => "scattered showers",
    41 => "heavy snow",
    42 => "scattered snow showers",
    43 => "heavy snow",
    44 => "partly cloudy",
    45 => "thundershowers",
    46 => "snow showers",
    47 => "isolated thundershowers",
    3200 => "not available"
    }

  class Forecast
    include SMG::Resource

    extract "yweather:forecast"   , :at => :low
    extract "yweather:forecast"   , :at => :high
    extract "yweather:forecast"   , :at => :day
    extract "yweather:forecast"   , :at => :date  , :class => :datetime
    extract "yweather:forecast"   , :at => :code  , :class => :integer
    extract "yweather:forecast"   , :at => :text

    def condition
      CONDITION_CODES[code]
    end

  end

  class Condition
    include SMG::Resource

    extract "yweather:condition"  , :at => :temp
    extract "yweather:condition"  , :at => :date
    extract "yweather:condition"  , :at => :text
    extract "yweather:condition"  , :at => :code  , :class => :integer

    def condition
      CONDITION_CODES[code]
    end

  end

  class Units
    include SMG::Resource

    extract "yweather:units"      , :at => :temperature
    extract "yweather:units"      , :at => :distance
    extract "yweather:units"      , :at => :pressure
    extract "yweather:units"      , :at => :speed
  end

  class Atmosphere
    include SMG::Resource

    extract "yweather:atmosphere" , :at => :humidity
    extract "yweather:atmosphere" , :at => :visibility
    extract "yweather:atmosphere" , :at => :pressure
    extract "yweather:atmosphere" , :at => :rising
  end

  class Location
    include SMG::Resource

    extract "yweather:location"   , :at => :city
    extract "yweather:location"   , :at => :region
    extract "yweather:location"   , :at => :country
  end

  class Wind
    include SMG::Resource

    extract "yweather:wind"       , :at => :chill
    extract "yweather:wind"       , :at => :direction
    extract "yweather:wind"       , :at => :speed
  end

  include SMG::Resource

  root 'rss/channel'

  extract "lastBuildDate"         , :as => :built_at
  extract "yweather:astronomy"    , :at => :sunrise
  extract "yweather:astronomy"    , :at => :sunset
  extract "yweather:location"     , :as => :wind        , :class => Location
  extract "yweather:units"        , :as => :units       , :class => Units
  extract "yweather:atmosphere"   , :as => :atmosphere  , :class => Atmosphere
  extract "yweather:wind"         , :as => :wind        , :class => Wind

  root 'rss/channel/item'

  extract "geo:lat"               , :as => :latitude
  extract "geo:long"              , :as => :longitude
  extract "title"                 , :as => :title
  extract "yweather:condition"    , :as => :current     , :class => Condition
  collect "yweather:forecast"     , :as => :forecasts   , :class => Forecast

end

data = File.read(ROOT.join('spec/fixtures/yahoo.weather.com.xml'))
yweather = YWeather.parse(data)

# EOF