require 'prawn'
require 'sequel'
require 'csv'
require 'fileutils'
require "sunnyside/version"
require 'sunnyside/cash_receipts/cash_receipt'
require 'sunnyside/cash_receipts/ics'
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

module Sunnyside
  # doesn't work on some Windows machines
  LOCAL_FILES = 'C:/sunnyside-files'
  if !Dir.exist?(LOCAL_FILES)
    ['db', '835', '837', '']
    Dir.mkdir('C:/')
  # Instead of creating a new DB, the gem will assume you already have one created
  # and have already seeded the DB with provider and client data

  # raise 'Database file missing!' if File.exist?("#{LOCAL_FILES}/db/sunnyside.db") 

  DB = Sequel.connect("sqlite:/#{LOCAL_FILES}/db/sunnyside.db")  

  # Second database for copying old data

  if DB.tables.empty?
    require 'sunnyside/models/db_setup'
    TT = Sequel.connect("sqlite:/#{LOCAL_FILES}/db/project.db")
    Sunnyside.create_tables
    Sunnyside.add_providers
    Sunnyside.add_ftp_data
    Sunnyside.add_clients
  end
  require 'sunnyside/models/sequel_classes'
end
