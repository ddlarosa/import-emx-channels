#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# init.rb
# RMS playlists loader from EMX
#

require_relative 'config/base'

puts "#{IMPORTXML::Config[:db][:host]}"
puts "#{IMPORTXML::Config[:db][:user]}"
puts "#{IMPORTXML::Config[:db][:password]}"
puts "#{IMPORTXML::Config[:db][:database]}"
puts "#{IMPORTXML::Config[:paths][:import_emx_channels_root]}"
puts "#{IMPORTXML::Config[:paths][:xml_channels_dir]}"

