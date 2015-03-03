#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# rmsploader.rb
# RMS playlists loader from EMX
#

require_relative 'config/base'
require 'optparse'
require 'optparse/time'
require 'ostruct'

#The number of day to process
number_day=nil

options = OpenStruct.new

OptionParser.new do |opts|
  opts.banner = "usage:\n\t#{$0} integer (number of day, 0 is today)"
  opts.separator ""
  #opts.on("-d", "--date [DATE]", "Force today's (or provided) date") do |d|
  #  if d.nil? or d.empty?
  #    options.forced_date = Date.today
  #  else
  #    options.forced_date = Date.parse d
  #  end
  #end
  #opts.on("-l", "--log FILE", "Dump SQL log to file") do |f|
  #  options.sql_log = f
  #end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

if ARGV.size < 1
  puts "ERROR: must provide an Integer (number of day) to process, see --help"
  exit
elsif
  begin
    number_day=Integer(ARGV[0])
  rescue
    puts "ERROR: must provide an Integer (number of day) to process, see --help"
    exit  
  end  
end

puts "Number of day to process #{number_day}"
