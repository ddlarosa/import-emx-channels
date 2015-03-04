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

#Remove the old playlists
remove_old_playlists

#Get the new xml playlist to process (EMX)
xmls_to_process=get_emx_to_process(xml_path,date) 

xmls_to_process.each do |xml_file|
 
 puts "Processing the file #{xml_file}"

 #This is the mount point of the chanel
 channel_id=""

 #Parse the xml playlist to process  
 playlist=read_emx_xml(xml_file) 
 
 #Create the new channels 
 if (check_channel(playlist.channel_number)==0)
   channel_id=create_channel(playlist.channel_id, playlist.channel_name)
 elsif
   channel_id=get_channel_id(playlist.channel_number)
 end
 
 #Insert the new songs into system 
 playlist=exists_songs(playlist)

 new_songs=Array.new

 playlist.songs.each do |song|
   new_songs << song unless song.db_exists
 end 

 insert_songs(new_songs) unless new_songs.count <= 0 

end 
