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

def read_xml_bdhits bdhits_file_xml

playlists = Array.new
  reader = Nokogiri::XML::Reader(File.open bdhits_file_xml)
   reader.each do |node|
    if node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      if node.name == 'CANCION'  # /playlists/playlist/song
        begin
          song = Song.new
          song.title = CGI::unescape_html node.attribute('titulo')
          song.duration = node.attribute('duracion').to_i
          song.artist = CGI::unescape_html node.attribute('interprete')
	  song.file = node.inner_xml.split('/').last.gsub(/.ogg/,'')
          song.init_hour = node.attribute('fecha')
          song.db_exists = false
          playlists.last.push_song song 
        rescue StandardError => e
          errors += 1
          puts "\tERROR parsing item #{n}: #{e.message}"
        end
      elsif node.name == 'PLAYLIST'  # /playlists/playlist
         begin
          playlist = Playlist.new
          playlist.channel_number = CGI::unescape_html node.attribute('canal')
	  playlist.channel_name = CGI::unescape_html node.attribute('nombrecanal')
          playlists << playlist
        rescue StandardError => e
          errors += 1
          puts "\tERROR parsing item #{n}: #{e.message}"
        end
      elsif node.name == 'playlists'  # /playlists
        puts "ENTAMOS EN PLAYLISTS"
      end
    end
  end 
  return playlists
end
