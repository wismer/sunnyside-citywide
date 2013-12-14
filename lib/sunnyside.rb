require 'prawn'
require 'sequel'
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
  folders     = ["835", "837", "summary", "db", "new-ledger", "cash_receipts", "private"]
  LOCAL_FILES = ENV["HOME"] + "/sunnyside-files/"
  puts "checking local folders for appropriate files..."
  if !Dir.exist?(LOCAL_FILES)
    puts "Creating folders..."
    Dir.mkdir(LOCAL_FILES)
    folders.each { |folder| Dir.mkdir("#{LOCAL_FILES}#{folder}") }
  end
  require 'sunnyside/models/sequel_classes'
end
