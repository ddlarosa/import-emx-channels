#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# rmsploader.rb
# RMS playlists loader from EMX
#

require_relative 'config/base'
require_relative 'lib/utils'
require_relative 'lib/xmlbdhits'
require_relative 'lib/db'
require 'pp'
require 'optparse'
require 'optparse/time'
require 'ostruct'

LOG.info("Inicio ejecucion rmsploaderbdhits")

#The number of day to process
number_day=nil
xml_path="#{IMPORTXML::Config[:paths][:xml_bdhits_channels]}/"

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
date_time=Time.parse date

#Remove the old playlists
remove_old_playlists

bdhits_file=date_time.strftime("%d%m%Y")
bdhits_file_xml="#{xml_path}#{bdhits_file}.xml"

#Get the new xml playlist to process (BDHITS)
 
puts ""
puts "***********************************************************"
puts "Processing channel #{bdhits_file_xml}"

#This is the mount point of the chanel
channel_id=""

#Parse the xml playlist to process  
playlists=read_xml_bdhits(bdhits_file_xml) 

playlists.each do |playlist| 
  #Modify channel_number three digits with zeros 
  playlist.channel_number=get_num_channel(playlist.channel_number)
  
  #Create the new channels 
  if (check_channel(playlist.channel_number)==0)
    playlist.channel_id=create_channel(playlist.channel_number, playlist.channel_name)
    create_mountpoint(playlist.channel_id,playlist.channel_number)
  elsif
    playlist.channel_id=get_channel_id(playlist.channel_number)
  end

  #Insert the new songs into system 
  playlist=exists_songs(playlist)

  new_songs=Array.new

  playlist.songs.each do |song|
    new_songs << song unless song.db_exists
  end 

  insert_songs(new_songs) unless new_songs.count <= 0 

  #Remove the same playlist into the same day that we are processing
  remove_playlist_channel_date(playlist.channel_id,date)
 
  #Insert playlist with time
  insert_playlist_calendar playlist
  puts "***********************************************************"

  LOG.info("Fin ejecucion rmsploaderbdhits")
end
