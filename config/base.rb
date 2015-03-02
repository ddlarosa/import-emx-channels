# -*- mode: ruby; coding: utf-8 -*-

module IMPORTXML

  Config = {

    # Application version
    version: File.open(File.expand_path("../../version", __FILE__)).gets.strip,

    db: {
      # DB server
      host: 'localhost',

      # DB user
      user: 'rmx',

      # DB password
      password: 'rmx',

      # Database
      database: 'rmx',
    },

    paths: {
      # RMX root with the directories rmxdb, rmxpanel, rmxserv, rmxproto, rmxstream
      import_emx_channels_root: File.expand_path("../..", __FILE__),

      # Temporal directory to upload audio files to
      xml_channels_dir: File.expand_path("../../xml", __FILE__),
    }
    
  }
    
end
