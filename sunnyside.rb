require 'sequel'
require 'prawn'
require 'csv'
require 'date'
require 'pp'
require 'fileutils'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'lib/menu'
require 'lib/ftp'
require 'lib/expiring_auth'
require 'lib/reports'
require 'lib/cash_receipts'
require 'lib/ledger'
require 'lib/models'

Sunnyside::Menu.new.start