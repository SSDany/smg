require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

require 'zlib'

module Discogs

  def self.search(t,q)
    Discogs::Search.get("search",
      :query => {"type" => t, "q" => q},
      :headers => {"Accept-Encoding" => "gzip,*;q=0"}) do |response|
      Zlib::GzipReader.new(StringIO.new(response.body)).read
    end
  end

  class Search

    include SMG::Resource
    include SMG::HTTP

    class ExactResult
      include SMG::Resource
      extract 'result', :at => 'type', :as => :resource_type
      extract 'result/title'
      extract 'result/uri'
    end

    class Result
      include SMG::Resource
      extract 'result', :at => 'type', :as => :resource_type
      extract 'result/title'
      extract 'result/uri'
      extract 'result/summary'
    end

    site "http://www.discogs.com"
    params "f" => "xml", "api_key" => "API_KEY"

    root 'resp'
    collect 'exactresults/result', :as => :exactresults, :class => ExactResult
    collect 'searchresults/result', :as => :results, :class => Result

  end

end

search = Discogs.search("all", "Genosha Recordings")

puts <<-RESULT
    type: #{search.exactresults.first.resource_type}
   title: #{search.exactresults.first.title}
     URI: #{search.exactresults.first.uri}
   total: #{search.results.size}
RESULT

#    type: label
#   title: Genosha Recordings
#     URI: http://www.discogs.com/label/Genosha+Recordings
#   total: 20

# EOF