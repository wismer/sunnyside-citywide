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
  LOCAL_FILES = ENV["HOME"] + "/sunnyside-files"
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
