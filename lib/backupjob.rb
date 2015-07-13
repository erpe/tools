#!/usr/bin/env ruby
#
# a simple database backup-script

require 'optparse'
require 'ostruct'
require 'date'

class BackupJob

  VERSION = 0.1
  
  # expects pgpass set for effektive userid
  #
  def initialize(argv)
    op = option_parser
    op.parse!(argv)
    check_options
  end
  
  def run
    process 
  end

  private

  def process
    puts "running version: #{VERSION}"
    system dump_cmd
  end

  def create_db_backup_filename
    ds = Date.today.to_s  
    f_name = "#{ds}-#{@options.database}.dump"
  end

  def dump_cmd
    cmd = if @options.no_password
            "pg_dump -U #{@options.user} #{@options.database} -f #{File.join(target_dir, create_db_backup_filename)}"
          else
            "pg_dump -U #{@options.user} -h localhost #{@options.database} -f #{File.join(target_dir, create_db_backup_filename)}"
          end
    puts cmd
    cmd
  end


  def option_parser
    @options = OpenStruct.new 

    op = OptionParser.new do |opts|
      opts.banner = "Usage: backupjob.rb [options]"

      opts.on("-d DATABASE", "--database DATABASE",
             "The mandatory database-name") do |d|
        @options.database = d
      end

      opts.on("-u USER", "--user USER",
             "The mandatory username") do |u|
        @options.user = u
      end  

      opts.on("-t TARGET", "--target TARGET",
             "The optional target-dir") do |t|
        @options.target_dir = t
      end

      opts.on("-n", "--no-password",
             "use no password") do |n|
        @options.no_password = true
      end
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    @options.op = op
    op
  end

  def check_options
    if @options.database.nil? || @options.user.nil?
      puts @options.op
      puts @options
      exit 1
    else
      puts "options okay"
    end
  end

  def target_dir
    @options.target_dir || "~/"
  end

end

job = BackupJob.new(ARGV)
job.run
