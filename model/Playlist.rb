#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# Song.rb
# Model a Song  
#

class Playlist 
  attr_accessor :channel_number, :channel_name, :songs 

  def initialize
    @songs = Array.new
  end

  def push_song song
    @songs << song
  end

end
