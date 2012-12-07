#!/usr/bin/ruby
# Memory Usage Check
# This calls ohai and then evalutes the returned values.
# Values for critical and warning levels are given in percentages
# from the command line; first WARN% then CRITCAL%.

if !ARGV[0] 
  puts "You must supply first then warn-level %, then critical-level %."
  puts "Example: check-memory 90 95"
  exit
end

if !FileTest.exists?("/usr/bin/ohai")
  puts "This check depends on ohai and it's missing !!"
  exit
end

require 'rubygems'
require 'json'
require 'sensu-plugin/check/cli'

class CheckMemoryUsage < Sensu::Plugin::Check::CLI
  def run
    warn_level = ARGV[0].to_i
    critical_level = ARGV[1].to_i

    ohai_output = `ohai`
    # slurp the json into a hash called stats
    stats = JSON.parse ohai_output

    free = stats['memory']['free'].to_f
    total = stats['memory']['total'].to_f
    usage = (((total - free) / total)*100).round
    message = "Memory usage at #{usage}%"

    if (usage  >= warn_level && usage < critical_level )
      warning message
    elsif  usage >= critical_level
      critical message
    else
      ok message
    end
  end
end
