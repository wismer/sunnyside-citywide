require 'prawn'
require 'sequel'
require 'csv'
require 'fileutils'
require_relative 'sunnyside/base.rb'
# require "sunnyside/version"
# require 'sunnyside/cash_receipts/cash_receipt'
# require 'sunnyside/ledger/ledger'
# require 'sunnyside/ledger/edi'
# require 'sunnyside/ledger/auth_report'
# require 'sunnyside/ledger/private'
# require 'sunnyside/reports/pdf_report'
# require 'sunnyside/reports/private'
# require 'sunnyside/reports/report'
# require 'sunnyside/query/query'
# require 'sunnyside/ftp'
# require 'sunnyside/menu'
# require 'sunnyside/expiring_auth'
# require 'sunnyside/models/db_setup'
# require 'sunnyside/advanced'

module Sunnyside
  # DRIVE   = ENV["HOMEDRIVE"]
  
  # Sunnyside.create_folders if !Dir.exist?("#{DRIVE}/sunnyside-files")
  # Dir.chdir("R:/Departments/AR Department")
  # DB = Sequel.connect("sqlite://sunnyside.db")

  # if DB.tables.empty?
  #   Sunnyside.create_tables
  #   Sunnyside.add_providers
  #   Sunnyside.add_denial_data
  # end

  # require 'sunnyside/models/sequel_classes'
end
