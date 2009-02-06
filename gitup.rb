#!/usr/bin/env ruby

class Gitup
  DEFAULT_APPLICATION = 'Transmit'
  
  def initialize(argv)
    # Set default application
    @application = DEFAULT_APPLICATION
    # Parse ARGV for application option.
    # This is awkward, but I'm too lazy to learn how to use OptionParser.
    argv.join('|').scan(/--application=[\w\s]+/) do |app|
      @application = app.match(/[\w\s]+$/)[0]
      argv.delete app
    end
    # This option is a bit easier to find.
    @skip_preview = argv.delete('-s') || argv.delete('--skip-preview')
    # Do the help thing.
    if argv.include?('-h') || argv.include?('--help')
      @help = true
    elsif argv.empty?
      # This just asks git-log for the last commit
      @options = '-1'
    else
      # If any other options/arguments are given, just pass them on to git-log
      @options = []
      argv.each do |arg|
        # Make sure options with a space are quoted
        @options<< arg.gsub(/=((.*\s)+.*)$/, '="\1"')
      end
    end
    @git_dir = `git rev-parse --show-cdup`.strip
    @ignore_file = @git_dir + '.gitupignore'
  end

  # Do the thing
  def process!
    if @help
      help
    elsif commits.empty?
      puts "No files found."
    else
      if @skip_preview
        upload_files
      else
        prompt
      end
    end
  end

  # Get the file list from git-log
  def git_log
    @git_log ||= `git log --name-status --relative --pretty=format:">>> %h %s" #{@options}`
  end

  # Get groups of files (grouped by commit)
  def commits
    @commits ||= git_log.split(/^\n?>>> /).collect do |group|
      files = group.split("\n")
      # The name is the commit message
      name = files.shift
      # What's left is the list of files
      files.collect! do |file|
        # Collect the ones that were added or modified
        file.sub(/[AM]\t/, '') if file =~ /[AM]\t/
      end
      # Get rid of the nils
      files.compact!
      # We don't want any files that have been deleted
      files.delete_if { |file| !File.exists?(file) }
      # Exclude files matching .gitupignore
      if File.exists?(@ignore_file)
        @ignores = File.readlines(@ignore_file).collect { |line| line.strip }
        @ignores.each do |ignore|
          files.delete_if { |file| file.match(ignore) }
        end
      end
      # Make the hash for the commit
      { :name => name, :files => files } unless name.nil? || files.nil? || files.empty?
    end.compact 
  end

  # Get the entire list of files
  def file_list
    files = commits.collect { |commit| commit[:files] }.flatten
  end

  # Displays help info
  def help
    puts "
      Usage: gitup.rb [-s|--skip-preview] [--application=<app_name>] <git-log options>
      Calling gitup.rb without arguments will build the file list from the most recent commit.
      See Commit Limiting in git-log help for options on specifying the commits.

      Other options:
        --application=<app_name>   Specify an application other than Transmit.
        -h, --help                 Show this message.
        -s, --skip-preview         Send files straight to Transmit without a prompt.
      "
  end

  # Lists commits and prompts for action
  def prompt
    # List commits and file counts
    commits.each do |commit|
      puts commit[:files].size.to_s.rjust(6) + ' Files:' + commit[:name]
    end
    # Prompt for action
    print "Continue/List Files/Abort [Cla] "
    input = STDIN.gets.chomp.strip.downcase
    # Respond accordingly
    case input
    when 'l'
      list_files
    when 'c', ''
      upload_files
    when 'a'
      puts "  Aborted"
      exit
    else
      prompt
    end
  end

  # Sends files to Transmit
  def upload_files
    puts "Files sent to #{@application}!"
    puts `open -ga '#{@application}' #{file_list.collect{|file| '"' + file + '"' }.join(' ')}`
  end

  # Displays the complete file list
  def list_files
    commits.each do |commit|
      puts "========================================================="
      puts "Files: #{commit[:name]}"
      puts "---------------------------------------------------------"
      puts commit[:files].join("\n")
    end
    puts "========================================================="
    prompt
  end

end

Gitup.new(ARGV).process!
