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

require 'net/smtp'
require 'logger'
require 'pp'
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'yaml'

#Channels permit to process
channels_permit=IMPORTXML::Config[:channels_permit_emx][:channels]

#Logged the init process
LOG.info("Inicio ejecucion rmsploader") 

#The number of day to process
number_day=nil

#The xml file to process
xml_path="#{IMPORTXML::Config[:paths][:xml_emx_channels]}/"

#Get parameters via command line 
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

#Get the date (Depens on number day)
date = get_date_loader number_day

#Remove the old playlists
remove_old_playlists
puts ""

#Get the new xml playlist to process (EMX)
xmls_to_process=get_emx_to_process(xml_path,date)

#Check if exists all xml files
channels_xmls=get_xml_channel_num xmls_to_process
channels_missed = channels_permit - channels_xmls

if channels_missed.count > 0
  puts "FALTAN PLAYLISTS PARA LOS CANALES #{channels_missed} en el día #{date}"
  
  user=IMPORTXML::Config[:mail][:user]
  password=IMPORTXML::Config[:mail][:password]
  channel_missed_str=channels_missed.join(",")
  
  message = <<EOF
From: SENDER <ddlarosa@musicam.es>
To: RECEIVER <david.ruizdelarosa@gmail.com>
Subject: Missed xml playlists into stream
Faltan playlists para los canales #{channel_missed_str} en el día #{date} 
EOF
  
  smtp = Net::SMTP.new 'smtp.gmail.com', 587
  smtp.enable_starttls
  smtp.start('gmail.com', "#{user}", "#{password}", :login) do |smtp|
    smtp.send_message message, "#{user}", 'david.ruizdelarosa@gmail.com'
  end
  exit
end

#Process all xml files 
xmls_to_process.each do |xml_file|
 
 if valid_emx_channel(xml_file,channels_permit)

   puts ""
   puts "***********************************************************"
   puts "Processing channel #{xml_file}"

   #This is the mount point of the chanel
   channel_id=""

   #Parse the xml playlist to process  
   playlist=read_emx_xml(xml_file) 
 
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
   insert_playlist_calendar(playlist)
 
   #Logged the end process
   puts "***********************************************************"
   
 end

end 
LOG.info("Fin ejecucion rmsploader")
