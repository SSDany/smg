require 'pathname'

ROOT = Pathname(__FILE__).dirname.expand_path.parent

dir = ROOT.join('lib').to_s
$:.unshift(dir) unless $:.include?(dir)

require 'smg'

begin

  require "rbench"

rescue LoadError
  $stderr << "You should have rbench installed in order to run benchmarks.\n" \
             "Try $gem in rbench\n" \
             "or take a look at http://github.com/somebee/rbench\n"
end
# EOF