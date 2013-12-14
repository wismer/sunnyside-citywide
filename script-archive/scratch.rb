require 'prawn'
require "csv"
PDF::Reader.new('./weekly-summary/20130904_9075_004.PDF').pages.each do |page|
  page.raw_content.scan(/\(([0-9\/]+)\s+(\d+)\s+(.{26})(\d+)\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.,]+)/) do |line|
    print "#{line}\n"
  end
end

# [12312, 32434, 45345, 12334245, 56567, 2342346, 567767, 23456, 23425]


VARIABLE = 'CONSTANT OR MODULE'
