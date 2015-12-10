#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#Copyright © 2015 slackr <slackr@openmailbox.org>
#This work is free. You can redistribute it and/or modify it under the
#terms of the Do What The Fuck You Want To Public License, Version 2,
#as published by Sam Hocevar. See the COPYING file for more details.

require 'ruby-progressbar'
require 'metainspector'
require 'open-uri'

link = ARGV.first.to_s
page = MetaInspector.new(link)
dl = page.links.http
dirname = page.best_title.gsub(/\W/, "_")


# creates a new directory
system 'mkdir', '-p', "#{dirname}"

# fetch the image links 
links = []
dl.each { |url| links.push(url) if url =~ /.jpg|.png/ }

# Progress bar
pb = ProgressBar.create(:title => "Image Fetched", :starting_at => 0, :total => links.length, :format => '%a [%b>%i] %c/%C %t %P%%')

links.each do |image|
		name = image.gsub(/\D+\d/, "")
		next if File.file?("#{dirname}\/#{name}")
		download = open(image)
		IO.copy_stream(download, "#{dirname}/#{name}")
		pb.increment
end

pb.finish
