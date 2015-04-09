#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# 
# 
#

def get_date_loader number_day
  date_loader=""
  number_day_sg=((24*60*60)*number_day)
  time=Time.new + number_day_sg

  date_loader=time.strftime("%Y%m%d")
  #date_loader="#{time.year}#{time.month}#{time.day}"
end


#Return a list of xml to process
def get_emx_to_process xml_path,date 
  #Get all xml from xml_path
  xml_files=Dir["#{xml_path}#{date}*.xml"]
end

def generate_unique_id
  date = Time.new.strftime("%M%S")
  random_number=(0...8).map {(65 + rand(26))}.join
  random_number+=date;
end

def convert_date_mysql date
  mysql_date=""
  date_arr=date.split(" ")
  date_aux=date_arr[0].split("/")
  mysql_date="#{date_aux[2]}-#{date_aux[1]}-#{date_aux[0]} #{date_arr[1]}" 
end

def get_num_channel num
  if num.length == 1 
    num="00"+num
  elsif num.length == 2
    num="0"+num
  end
  return num 
end

def show_channels_bdhits playlists 
  playlists.each do |playlist|
    puts "ID CHANNEL #{playlist.channel_number} ---- #{playlist.channel_name}"
  end
end

def show_first_last_bdhits playlists
  playlists.each do |playlist|
    puts "ID CHANNEL #{playlist.channel_number} ---- #{playlist.channel_name}" 
    songs=playlist.songs
    pp songs.first
    pp songs.last
    puts "*****************" 
  end
end

def valid_emx_channel xml_file,channels_permit
  xml_name_file=xml_file.split("/")[-1].gsub(".xml","")
  channel_num=xml_name_file.split("-")[-1].to_i
  return channels_permit.include?(channel_num)
end

def get_xml_channel_num arr_xml_channels
  
  my_channels=[]
  
  arr_xml_channels.each do |xml|
    pos_ini=xml.index(/-ch-/)
    pos_fin=xml.index(/\.xml/)
    my_channels << "#{xml[pos_ini+4,(pos_fin-(pos_ini+4))]}".to_i
  end
  
  return my_channels

end
