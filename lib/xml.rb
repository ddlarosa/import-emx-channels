#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# xml.rb
# 
#

require 'bundler/setup'
require 'nokogiri'
require_relative '../config/base'


BDHITS_XML=IMPORTXML::Config[:paths][:xml_bdhits_channels]
EMX_XML=IMPORTXML::Config[:paths][:xml_emx_channels]

def read_emx_xml emx_file
  pl=nil
  day=nil

  f="#{EMX_XML}/#{emx_file}"
  reader = Nokogiri::XML::Reader(File.open f)
   reader.each do |node|
    if node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      if node.name == 'CANCION'  # /playlists/playlist/song
        begin
          song_title = CGI::unescape_html node.attribute('titulo')
          puts "Song Title=#{song_title}"
          song_duration = node.attribute('duracion').to_i
          puts "Song Duration=#{song_duration}"
	  song_date = node.attribute('fecha')
          puts "Song Date=#{song_date}"
          song_artist = CGI::unescape_html node.attribute('interprete')
	  puts "Song Artist=#{song_artist}"
	  song_file = "#{node.inner_xml}"
	  puts "Song File =#{song_file}"
	  #song_hour = Time.strptime(node.attribute('init_hour'), "%T")
          #song_file = File.basename(node.attribute('file'))
          #raise "invalid file name '#{song_file}'" unless /^(?<song_id>\d+)\.ogg$/ =~ song_file
        rescue StandardError => e
          errors += 1
          puts "\tERROR parsing item #{n}: #{e.message}"
        end
     
      elsif node.name == 'playlist'  # /playlists/playlist
        puts "ENTRAMOS PLAYLIST" 
      elsif node.name == 'playlists'  # /playlists
        puts "ENTRAMOS PLAYLISTS" 
      end
    end
  end  
end

read_emx_xml "20150225-ch-25.xml"
