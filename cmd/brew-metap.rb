require 'keg'
require 'formula'
require 'shellwords'
require 'set'
require 'cmd/deps'

# I have no clue about ruby and this is my first attmpt to pointless script..

module BrewMetap

  USAGE = <<-EOS.undent
  DESCRIPTION
    `metap` is a way to manage your collection of various third party taps
    by embedding them in one sigle personally managed meta tap. The external 
    taps are transformed into prefixed subtree git repos with all their 
    history squashed into a single commit.

    Warning:

      Be cautious when integrating the external taps, as this command was  
      intended mainly to handle formulae and hence command and other kinds of 
      taps will most probably not be handled correctly.

  USAGE
    brew metap [--force] [--dry-run] [--quiet] user/tap

    Example:

      brew metap ravenac95/sudolikeaboss # Transforms the 'ravenac95/sudolikeaboss'
                                         # tap into a git subtree under the prefix
                                         # 'sub/sudolikeaboss' and sets the remote
                                         # 'sudolikeaboss' to track the remote tap.

  OPTIONS
    --force   [...]
    --dry-run [...]
    --quiet   [...]

  EOS
  
  
  @dry_run = false
  @used_by_table = {}
  @dependency_table = {}


  module_function
  
  def bash(command)
    escaped_command = Shellwords.escape(command)
    return %x! bash -c #{escaped_command} !
  end

  # replaces Kernel#puts w/ do-nothing method
  def puts_off
    Kernel.module_eval %q{
      def puts(*args)
      end
      def print(*args)
      end
    }
  end

  # restores Kernel#puts to its original definition
  def puts_on
    Kernel.module_eval %q{
      def puts(*args)
        $stdout.puts(*args)
      end
      def print(*args)
        $stdout.print(*args)
      end
    }
  end

  # Sets the text to output with the spinner
  def set_spinner_progress(txt)
    @spinner[:progress] = txt
  end

  def show_wait_spinner(fps=10)
    chars = %w[| / - \\]
    delay = 1.0/fps
    iter = 0
    @spinner = Thread.new do
      Thread.current[:progress] = ""
      progress_size = 0
      while iter do  # Keep spinning until told otherwise
        print ' ' + chars[(iter+=1) % chars.length] + Thread.current[:progress]
        progress_size = Thread.current[:progress].length
        sleep delay
        print "\b"*(progress_size + 2)
      end
    end
    yield.tap{       # After yielding to the block, save the return value
      iter = false   # Tell the thread to exit, cleaning up after itself…
      @spinner.join   # …and wait for it to do so.
    }                # Use the block's return value as the method's
  end
  
  def should_proceed_or_quit(prompt)
    puts ""
    unless should_proceed(prompt)
      puts ""
      onoe "User quit"
      exit 0
    end
    return true
  end

  def should_proceed(proceed=false)


  end
  #
  def metap(tap, force=false, quiet=false, dry_run=true)
    if !force
        return
      end
    end

    if @dry_run
      describe_build_tree(wont_remove_because)
      return
    end

    should_proceed_or_quit("Proceed?")
    ohai "Cleaning up packages safe to remove"

  def main
    force = false
    ignored_kegs = []
    metap = []
    quiet = false

    if ARGV.size < 1 or ['-h', '?', '--help'].include? ARGV.first
      puts USAGE
      exit 0
    end

    reraise KegUnspecifiedError if ARGV.named.empty?

    loop { case ARGV[0]
        when '--quiet' then ARGV.shift; quiet = true
        when '--dry-run' then ARGV.shift; @dry_run = true
        when '--force' then  ARGV.shift; force = true
        when /^-/ then  puts "Unknown option: #{ARGV.shift.inspect}"; puts USAGE; exit 1
        when /^[^-]/ then metap.push(ARGV.shift)
        else break
    end; }

    # Turn off output if 'quiet' is specified
    if quiet
      puts_off
    end

    if @dry_run
      puts "This is a dry-run, nothing will be deleted"
    end

    puts "metap"

    # Convert ignored kegs into full names
    # ignored_kegs.map! { |k| as_formula(k).full_name }
    # ohai.each { |keg_name| metap keg_name, force, ignored_kegs }
  end
end

BrewMetap.main

exit 0
