require 'pathname'
require 'rubygems'

begin

  gem 'rspec', '>=1.2'
  require 'spec'

  SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
  FIXTURES_DIR = SPEC_ROOT + 'fixtures'

  dir = SPEC_ROOT.parent.join('lib').to_s
  $:.unshift(dir) unless $:.include?(dir)
  require 'smg'

rescue LoadError
end

# EOF