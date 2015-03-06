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
      # root with the directories that contains xml files from EMX 
      xml_emx_channels: File.expand_path("../../xml/emx", __FILE__),

      # root with the directories that contains xml files from BDHITS
      xml_bdhits_channels: File.expand_path("../../xml/bdhits", __FILE__),

      # root with the directories that contains logs files 
      logs: File.expand_path("../../logs", __FILE__),
    },
    
    mountpoint: {
      # port used by icecast server  
      port:443,
      # icescast server ip 
      server_ip:'192.168.1.251',

    }
    
  }
    
end
