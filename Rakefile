require 'pathname'
require 'rubygems'
require 'rake'

ROOT = Pathname(__FILE__).dirname.expand_path
require ROOT + 'lib/smg/version'

require ROOT + 'tasks/spec'
require ROOT + 'tasks/benchmarks'
require ROOT + 'tasks/package'

task :default => :spec

# EOF