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

def channels_show 
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

