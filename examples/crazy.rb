require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class A
  include SMG::Resource
  extract "a"   , :as => :href    , :at => :href
  extract "a"   , :as => :content
end

class P
  include SMG::Resource
  extract "p"   , :as => :raw
  collect "p/a" , :as => :links   , :class => A
end

class Requirements
  include SMG::Resource
  root "div"
  extract "p"   , :as => :raw
  extract "p"   , :as => :p       , :class => P
  collect "p/a" , :as => :links   , :class => A
end

data = <<-HTML
<div><p>Requirements: <a href="http://github.com/tenderlove/nokogiri">nokogiri</a> and <a href="http://github.com/sporkmonger/addressable">addressable</a>.</p></div>
HTML

parsed = Requirements.parse(data)

puts parsed.raw                           #=> "Requirements: nokogiri and addressable."
puts parsed.links.map { |a| a.href }      #=> ["http://github.com/tenderlove/nokogiri", "http://github.com/sporkmonger/addressable"]
puts parsed.links.map { |a| a.content }   #=> ["nokogiri", "addressable"]

puts parsed.p.raw                         #=> "Requirements: nokogiri and addressable."
puts parsed.p.links.map { |a| a.href }    #=> ["http://github.com/tenderlove/nokogiri", "http://github.com/sporkmonger/addressable"]
puts parsed.p.links.map { |a| a.content } #=> ["nokogiri", "addressable"]

# EOF