#!/usr/bin/env ruby
# dups.rb - a tiny utility that removes duplicate files
# 	from a given directory.
#
# @author	:rmNULL
# @license	:public
#
# TODO: 
#  1. Add support for recursive deletion.
#  2. Improve interactive mode interface.
#  3. Deal with directories and links.
require 'digest'
require 'optparse'

def possible_dups(dir)
        files = {}

        Dir.foreach(dir) do |f|
                f = File.join(dir, f)
                size = File.size? f
                next if File.directory? f || size

                unless files[size]
                        files[size] = f
                else
                        yield files[size], f
                end
        end
end

def find_dups(dir)
        dups = []
	md5 = Digest::MD5.new

	return unless File.directory? dir

        possible_dups(dir) do |f1, f2|

		org = md5.file(f1).hexdigest
		md5.reset

                possible_dup = md5.file(f2).hexdigest
                md5.reset

                if org == possible_dup
                        dups << dup
                end
	end

	dups
end

args = {}
arguments = OptionParser.new do |arg|

        RESET = "\e[0m"
        YELLOW = "\e[33m"
        BOLD = "\e[01m"

	# hate doing this.
	arg.banner = <<USAGE
#{YELLOW}#{__FILE__}#{RESET}: A simple utility to remove duplicates from a given directory.

#{BOLD}Usage#{RESET}: #{__FILE__} [options]...

Options:
USAGE

	arg.on("-d", "--dir DIRECTORY", "directory to find duplicates") do |dir|
		args[:dir] = dir
	end

	arg.on("-f", "--force", "remove without prompting.") do
		args[:del] = true
	end
	
	arg.on("-h", "--help", "print this message") do
		puts arguments
		exit
	end
end

arguments.parse!

if args[:dir]
	dups = find_dups File.expand_path(args[:dir])
else
	dups = find_dups Dir.pwd
end


if args[:del]
	# for log filename
	date = Time.now.strftime("%b-%d-%Y")
	secs = Time.now.to_i
	file_name = "/tmp/#{date}_#{secs}_del.log"

	if dups.length > 0
		File.open(file_name, "w") do |fh|
			dups.each do |file|
				File.unlink file
				fh << file << "\n"
			end

			puts "#{dups.length} files deleted"
			puts "log written to: #{file_name}"
		end
	end
else
	dups.each do |file|
		print "Delete #{File.basename(file)}? "

		if gets.strip =~ /^[yY]/
			File.unlink file
		end
	end
end
