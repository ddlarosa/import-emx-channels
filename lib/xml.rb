#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# xml.rb
# 
#

require 'bundler/setup'
require 'nokogiri'
require 'pp'
require_relative '../config/base'
require_relative '../model/Song'
require_relative '../model/Playlist'

def read_emx_xml emx_file
  
playlist=Playlist.new

  reader = Nokogiri::XML::Reader(File.open emx_file)
   reader.each do |node|
    if node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      if node.name == 'CANCION'  # /playlists/playlist/song
        begin
          song = Song.new
          song.title = CGI::unescape_html node.attribute('titulo')
          song.duration = node.attribute('duracion').to_i
          song.artist = CGI::unescape_html node.attribute('interprete')
	  song.file = "#{node.inner_xml}"
          song.init_hour = node.attribute('fecha')
          playlist.push_song song 
        rescue StandardError => e
          errors += 1
          puts "\tERROR parsing item #{n}: #{e.message}"
        end
      elsif node.name == 'PLAYLIST'  # /playlists/playlist
         begin
          playlist.channel_id = CGI::unescape_html node.attribute('canal')
	  playlist.channel_name = CGI::unescape_html node.attribute('nombrecanal')
        rescue StandardError => e
          errors += 1
          puts "\tERROR parsing item #{n}: #{e.message}"
        end
      elsif node.name == 'playlists'  # /playlists
        puts "ENTRAMOS PLAYLISTS" 
      end
    end
  end 
  pp playlist
end

