#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# rmsploader.rb
# RMS playlists loader from EMX
#

require_relative 'config/base'
require_relative 'lib/utils'
require_relative 'lib/xml'
require_relative 'lib/db'
require 'pp'
require 'optparse'
require 'optparse/time'
require 'ostruct'

#The number of day to process
number_day=nil
xml_path="#{IMPORTXML::Config[:paths][:xml_emx_channels]}/"

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

#Get the date depens on number day
date = get_date_loader number_day

remove_old_playlists

xmls_to_process=get_emx_to_process(xml_path,date) 

xmls_to_process.each do |xml_file|
 channel_id=""

 #Get the playlist belongs to this channels and date 
 playlist=read_emx_xml(xml_file) 

 if (check_channel(playlist.channel_number)==0)
   channel_id=create_channel(playlist.channel_id, playlist.channel_name)
 elsif
   channel_id=get_channel_id(playlist.channel_number)
 end

 puts "Processing the file #{xml_file} #{channel_id}"

end 
