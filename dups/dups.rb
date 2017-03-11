#!/usr/bin/env ruby
# dups.rb - a tiny utility that removes duplicate files
# 	from a given directory.
#
# @author	:rmNULL
# @version	:0.0.2
# @license	:public
#
# TODO: 
#  1. Add support for recursive deletion.
#  2. Improve interactive mode interface.

require 'digest'
require 'optparse'

def find_dups(dir)
	dups = []
	files = {}
	md5 = Digest::MD5.new

	return unless File.directory? dir

	Dir.foreach(dir) do |f|
		f = File.join(dir, f)
		next if File.directory? f

		hash = md5.file(f).hexdigest
		md5.reset

		unless files[hash]
			files[hash] = f
		else
			dups << f
		end
	end

	return dups
end

args = {}
arguments = OptionParser.new do |arg|

	# i hate doing this.
	arg.banner = <<USAGE
\e[33m#{__FILE__}\e[0m: A simple utility to remove duplicates from a given directory.

\e[1mUsage\e[0m: #{__FILE__} [options]...

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
