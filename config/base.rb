# -*- mode: ruby; coding: utf-8 -*-

module IMPORTXML

  Config = {

    # Application version
    version: File.open(File.expand_path("../../version", __FILE__)).gets.strip,

    db: {
      # DB server
      host: 'localhost',

      # DB user
      user: 'root',

      # DB password
      password: 'musicam',

      # Database
      database: 'rms',
    },

    paths: {
      # RMX root with the directories rmxdb, rmxpanel, rmxserv, rmxproto, rmxstream
      xml_emx_channels: File.expand_path("../../xml/emx", __FILE__),

      xml_bdhits_channels: File.expand_path("../../xml/bdhits", __FILE__),

    },
    
    mountpoint: {
    
      port:443,
      server_ip:'192.168.1.251',

    }
    
  }
    
end
