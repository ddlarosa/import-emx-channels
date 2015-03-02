#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# db.rb
# Connect and execute query to database
#

require 'bundler/setup'
require "mysql2"
require_relative '../config/base'


def check_db
  begin
    con=Mysql2::Client.new(host:IMPORTXML::Config[:db][:host], username:IMPORTXML::Config[:db][:user], 
	          password:IMPORTXML::Config[:db][:password], database:IMPORTXML::Config[:db][:database]);
  rescue Mysql2::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

