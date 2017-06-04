require 'keg'
require 'formula'
require 'cmd/deps'

module BrewRelink
  
  USAGE = <<-EOS.undent
  DESCRIPTION

    `relink` simply unlinks and relinks the required kegs. A shortcut to
    brew link formula && brew link formula.

  USAGE
    
    brew relink [--dry-run]  formula

  Example:

    brew relink bash

  OPTIONS

    --dry-run [...]
  
  EOS
  
  module_function
  
  @dry_run = false

      mode = OpenStruct.new
      mode.dry_run = true if ARGV.dry_run?

      if ARGV.size < 1 or ['-h', '?', '--help'].include? ARGV.first
        puts USAGE
        exit 0
      end
      
      raise KegUnspecifiedError if ARGV.named.empty?
      
      loop { case ARGV[0]
      when '--dry-run' then ARGV.shift; @dry_run = true
      when /^-/ then  puts "Unknown option: #{ARGV.shift.inspect}"; puts USAGE; exit 1
      else break
      end; }
      
      if @dry_run
        puts "This is a dry-run, nothing will be relinked"
      end
      
      ARGV.kegs.each do |keg|
        if mode.dry_run
          puts "Would remove:"
          keg.unlink(mode)
          next
        end
        
        keg.lock do
          print "Unlinking #{keg}... "
          puts if ARGV.verbose?
          puts "#{keg.unlink(mode)} symlinks removed"
        end
        
        ARGV.kegs.each do |keg|
          if mode.dry_run
            puts "Would add:"
            keg.link(mode)
            next
          end
          
          keg.lock do
            print "Linking #{keg}... "
            puts if ARGV.verbose?
            puts "#{keg.link(mode)} symlinks added"
          end
        end
      end
      
end

exit 0
