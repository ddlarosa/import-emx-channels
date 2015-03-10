#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# db.rb
# Connect and execute query to database
#

require 'bundler/setup'
require "mysql2"
require_relative '../config/base'
require 'logger'

#Database configuration
HOST=IMPORTXML::Config[:db][:host]
USERNAME=IMPORTXML::Config[:db][:user]
PASSWORD=IMPORTXML::Config[:db][:password]
DATABASE=IMPORTXML::Config[:db][:database]
MOUNTPOINTPORT=IMPORTXML::Config[:mountpoint][:port]
MOUNTPOINTIP=IMPORTXML::Config[:mountpoint][:server_ip]
LOGFILE_DIR=IMPORTXML::Config[:paths][:logs]

#Inizialite Log File
today=date=(Time.now-(15*60)).strftime("%Y%m%d")
logfile="#{LOGFILE_DIR}/#{today}"
LOG = Logger.new("#{logfile}", 'monthly')

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
    LOG.warn("Error al chequear el canal #{e.error}")
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
    LOG.warn("Error al recuperar el channel id #{e.error}")
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
    LOG.info("Creamos un el nuevo canal #{channel_description_escp}")

    rs=con.query("INSERT INTO channels (channel_id,channel_num,channel_description,channel_enabled) VALUES('#{channel_id}','#{channel_number}','#{channel_description_escp}',0)") 
    
    puts "The channel #{channel_name} has been created"
    return channel_id 
  rescue Mysql2::Error => e
    LOG.warn("Error al crear un canal nuevo #{e.error}")
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
    song.db_exists=true unless rs.count<=0
  end 

  return playlist

  rescue Mysql2::Error => e
    LOG.warn("Error al comprobar que existen canciones  #{e.error}")
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
      begin
       artist_escape=con.escape "#{song.artist}" 
       title_escape=con.escape "#{song.title}" 
       query="INSERT INTO playlists_files (file_id,file_path,file_length,file_artist,file_title) ";
       query+="VALUES ('#{song.file}','#{song.file}.ogg',#{song.duration},'#{artist_escape}','#{title_escape}')";
       con.query("#{query}");
       LOG.info("Insertando nueva cancion #{song.file}.ogg")   
      rescue Mysql2::Error => e2
        LOG.warn("La cancion #{e2.error} ya existe en la base de datos")
        puts e2.errno
        puts e2.error
      end
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
  LOG.info("Insertando playlists calendar para el canal #{channel_id}")
  rescue Mysql2::Error => e
    LOG.warn("Error al insertar playlists_calendar #{e.error}")
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
    LOG.warn("Error al eliminar playlists channel date #{e.error}")
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
    puts "DELETE FROM playlists_calendar WHERE calendar_datetime <= '#{date}'" 
    puts "Remove old playlist calendar from #{date} before";
    LOG.info("Eleminando antiguas playlists anteriores a #{date}")
  rescue Mysql2::Error => e
    LOG.warn("Error al playlists antiguas #{e.error}")
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

def create_mountpoint channel_id,channel_number
begin
    con=Mysql2::Client.new(host:HOST, username:USERNAME, password:PASSWORD, database:DATABASE);
    mountpoint_id=generate_unique_id

    sql="INSERT INTO mountpoints (mountpoint_id,channel_id,server_ip,server_port,server_path) "
    sql+="VALUES('#{mountpoint_id}',#{channel_id},'#{MOUNTPOINTIP}',#{MOUNTPOINTPORT},'/#{channel_number}.ogg')";
    con.query("#{sql}")
    puts "Creating mountpoint for #{channel_number}" 
    LOG.info("Creando punto de montaje para el canal #{channel_number}")
  rescue Mysql2::Error => e
    LOG.warn("Error al crear nuevos puntos de montaje #{e.error}")
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end
