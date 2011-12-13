# Nagios check script for god.  http://god.rubyforge.org/
# Big thanks to www.meteostar.com for open-sourcing this script.

require 'optparse'

OK = 0
WARNING = 1
CRITICAL = 2

def exit_with(status, message)
  puts message
  exit status
end

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: check_god.rb -v -V -h"

  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  opts.on( '-V', '--version', 'Output version information' ) do
    puts "Nagios god monitor version 1.0"
    exit OK
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit OK
  end
end

begin
  optparse.parse!
rescue OptionParser::InvalidOption => e
  exit_with( CRITICAL, e )
end

god_status = `sudo god status`
if $? != 0
  exit_with( CRITICAL, god_status )
end

puts "'god status' says:\n#{god_status}" if options[ :verbose ]

# split on newlines
items = god_status.split( "\n" ).map { |l|
  # split each line on spaces and remove leading/trailing whitespace
  l.split( ': ' ).map { |p| p.strip }
}
# reject group items, which have no status.
items.reject!{ |i| i.size != 2 }

status = OK
# critical if any watch is not 'up'
if items.select{ |i| i[ 1 ] != 'up' }.size > 0
  status = CRITICAL
end

exit_with( status, items.map{ |i| i.join( ':' ) }.join( ', ' ) )
