#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# db.rb
# Connect and execute query to database
#

require "mysql"
require_relative '../config/base'


def check_db
  begin
    con=Mysql.new IMPORTXML::Config[:db][:host], IMPORTXML::Config[:db][:user], 
	          IMPORTXML::Config[:db][:user], IMPORTXML::Config[:db][:dabase]
    puts "Connect sucessfully with RMS database"
  rescue Mysql::Error => e
    puts e.errno
    puts e.error
  ensure
    con.close if con
  end
end

check_db
