require 'pathname'
require 'rubygems'

gem 'nokogiri', '>=1.3'
require 'nokogiri'

require 'smg/mapping/element'
require 'smg/mapping/typecasts'
require 'smg/mapping'
require 'smg/model'
require 'smg/resource'
require 'smg/document'

# TODO: autoload [?]
require 'smg/http/request'
require 'smg/http/exceptions'

# EOF