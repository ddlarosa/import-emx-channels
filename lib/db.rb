#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# db.rb
# Connect and execute query to database
#

require 'bundler/setup'
require "mysql2"
require_relative '../config/base'

#Database configuration
HOST=IMPORTXML::Config[:db][:host]
USERNAME=IMPORTXML::Config[:db][:user]
PASSWORD=IMPORTXML::Config[:db][:password]
DATABASE=IMPORTXML::Config[:db][:database]

def check_db
  begin
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE); 
    puts "Succesfully connection"
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def show_channels 
  begin
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);

    rs = con.query("SELECT * FROM channels")

    rs.each do |row|
      puts "**** Channel ****"
      puts "Id=#{row['channel_id']}"
      puts "Num=#{row['channel_num']}"
      puts "Description=#{row['channel_description']}"
      puts "LastSong=#{row['channel_lastsong_id']}"
      puts "Enabled=#{row['channel_enabled']}"
      puts
    end

  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def check_channel channel_number
  begin
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
    rs = con.query("SELECT * FROM channels WHERE channel_num=#{channel_number}")
    rs.count

  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def get_channel_id channel_number
  begin
    channel_id=""
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
    rs = con.query("SELECT * FROM channels WHERE channel_num=#{channel_number}")

    rs.each do |row|
      channel_id=row['channel_id']
    end
   
    return channel_id

  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def create_channel channel_number, channel_name
  begin
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
    channel_id=generate_unique_id
    channel_description_escp=con.escape "#{channel_name}" 
    
    rs=con.query("INSERT INTO channels (channel_id,channel_num,channel_description,channel_enabled) VALUES('#{channel_id}','#{channel_number}','#{channel_description_escp}',0)") 
    
    puts "The channel #{channel_name} has been created"
    return channel_id 
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def exists_songs playlist

  begin
  con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
 
  playlist.songs.each do |song|
    rs=con.query("SELECT * FROM playlists_files WHERE file_id='#{song.file}'")
    #song=true unless rs.count<=0 
    song.db_exists=true unless rs.count<=0
  end 

  return playlist

  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def insert_songs songs
  begin
    puts "Insert new songs ..."
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
     
    songs.each do |song| 
      artist_escape=con.escape "#{song.artist}" 
      title_escape=con.escape "#{song.title}" 
      query="INSERT INTO playlists_files (file_id,file_path,file_length,file_artist,file_title) ";
      query+="VALUES ('#{song.file}','#{song.file}.ogg',#{song.duration},'#{artist_escape}','#{title_escape}')";
      con.query("#{query}");
    end 

  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def insert_playlist_calendar playlist 
 begin
  con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
  channel_id=playlist.channel_id
  songs=playlist.songs
  
  songs.each do |song| 
    calendar_id=generate_unique_id
    mysql_date=convert_date_mysql "#{song.init_hour}" 
    sql="INSERT INTO playlists_calendar (calendar_id,channel_id,file_id,calendar_datetime) ";
    sql+="VALUES ('#{calendar_id}','#{channel_id}','#{song.file}','#{mysql_date}')";
    con.query("#{sql}");
  end
  puts "Inserting playlists calendar for channel #{channel_id}"
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end 
end

def remove_playlist_channel_date channel_id,date 
 begin
    mysql_date="#{date[0..3]}-#{date[4..5]}-#{date[6..7]}"
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);

    con.query("DELETE FROM playlists_calendar WHERE channel_id='#{channel_id}' AND calendar_datetime LIKE '#{mysql_date}%'");
    puts "Remove playlist from channel #{channel_id} and date #{date}" 
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def remove_old_playlists
  begin
    date=(Time.now-(15*60)).strftime("%Y-%m-%d %H:%M:%S");
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
    con.query("DELETE FROM playlists_calendar WHERE calendar_datetime <= '#{date}'");
    puts "Remove old playlist calendar from #{date} before";
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end
