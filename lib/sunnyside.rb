require 'prawn'
require 'sequel'
require "sunnyside/version"
require 'sunnyside/cash_receipts/cash_receipt'
require 'sunnyside/cash_receipts/ics'
require 'sunnyside/ledger/ledger'
require 'sunnyside/ledger/edi'
require 'sunnyside/ledger/auth_report'
require 'sunnyside/ledger/private'
require 'sunnyside/models/sequel_classes'
require 'sunnyside/reports/pdf_report'
require 'sunnyside/reports/private'
require 'sunnyside/reports/report'
require 'sunnyside/ftp'
require 'sunnyside/menu'
require 'sunnyside/expiring_auth'

module Sunnyside
  LOCAL_FILES = ENV["HOME"] + "/project_files/"
  puts "checking local folders for appropriate files..."
  if Dir.exist?(LOCAL_FILES)
    Menu.new.start
  else
    puts "Creating folder..."
    Dir.mkdir(LOCAL_FILES + "/835")
    Dir.mkdir(LOCAL_FILES + "/837")
    Dir.mkdir(LOCAL_FILES + "/summary")
    Dir.mkdir(LOCAL_FILES + "/db")
    Dir.mkdir(LOCAL_FILES + "/new-ledger")
    Dir.mkdir(LOCAL_FILES + "/cash_receipts")
    Dir.mkdir(LOCAL_FILES + "/other")
    Menu.new.start
  end
end
