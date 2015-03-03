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
    
    rs=con.query("INSERT INTO channels (channel_id,channel_num,channel_description,channel_enabled) VALUES('#{channel_id}','#{channel_number}','#{channel_name}',0)") 
    
    puts "The channel #{channel_name} has been created"
    return channel_id 
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
    #puts "DELETE FROM playlists_calendar WHERE calendar_datetime <= '#{date}'" 
    con.query("DELETE FROM playlists_calendar WHERE calendar_datetime <= '#{date}'");

    puts "The query has affected #{con.affected_rows} rows"
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end
