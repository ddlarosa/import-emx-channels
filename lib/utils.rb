#!/usr/bin/env ruby
#                                    -*- mode: ruby; coding: utf-8 -*-
#
# 
# 
#

def get_date_loader number_day
  date_loader=""
  number_day_sg=((24*60*60)*number_day)
  time=Time.new + number_day_sg

  date_loader=time.strftime("%Y%m%d")
  #date_loader="#{time.year}#{time.month}#{time.day}"
end


#Return a list of xml to process
def get_emx_to_process xml_path,date 
  #Get all xml from xml_path
  xml_files=Dir["#{xml_path}#{date}*.xml"]
end
