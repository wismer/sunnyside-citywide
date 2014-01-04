require 'prawn'
require 'sequel'
require 'csv'
require 'fileutils'
require "sunnyside/version"
require 'sunnyside/cash_receipts/cash_receipt'
require 'sunnyside/ledger/ledger'
require 'sunnyside/ledger/edi'
require 'sunnyside/ledger/auth_report'
require 'sunnyside/ledger/private'
require 'sunnyside/reports/pdf_report'
require 'sunnyside/reports/private'
require 'sunnyside/reports/report'
require 'sunnyside/ftp'
require 'sunnyside/menu'
require 'sunnyside/expiring_auth'
require 'sunnyside/models/db_setup'

module Sunnyside
  DRIVE   = ENV["HOMEDRIVE"]
  
  Sunnyside.create_folders if !Dir.exist?("#{DRIVE}/sunnyside-files")
    
  DB = Sequel.connect("sqlite:/#{DRIVE}/sunnyside-files/db/sunnyside.db")

  if DB.tables.empty?
    Sunnyside.create_tables
    Sunnyside.add_providers
    Sunnyside.add_ftp_data
  end    

  require 'sunnyside/models/sequel_classes'
  # Since all computers at work are windows, this gem will be windows only.

  # LOCAL_FILES = ENV["HOMEDRIVE"] + '/sunnyside-files'
  # if !Dir.exist?("#{LOCAL_FILES}")
  #   Dir.mkdir("#{LOCAL_FILES}")
  #   ['db', '835', '837', 'summary', 'cash_receipts', 'new-ledger', 'private', 'summary'].each { |folder| Dir.mkdir("C:/#{LOCAL_FILES}/#{folder}") }
  # end

  # # raise 'Database file missing!' if File.exist?("#{LOCAL_FILES}/db/sunnyside.db") 

  # DB = Sequel.connect("sqlite:/#{LOCAL_FILES}/db/sunnyside.db")  

  # # Second database for copying old data

  # if DB.tables.empty?
  #   require 'sunnyside/models/db_setup'
  #   TT = Sequel.connect("sqlite:/#{LOCAL_FILES}/db/project.db")
  #   Sunnyside.create_tables
  #   Sunnyside.add_providers
  #   Sunnyside.add_ftp_data
  #   Sunnyside.add_clients
  # end
  # require 'sunnyside/models/sequel_classes'
end
