require 'csv'
require 'prawn'

module Parser

  def self.parse_files(file)
    PDF::Reader.new('./weekly-summary/' + file).pages.each do |page|
      page.raw_content.scan(/^\(([0-9\/]+)\s+(\d+)\s+([A-Z,\.]+\s[A-Z ,]+)\d+\s+([0-9\.]+)\s+([0-9\.]+)\s+([0-9\.,]+)/) do |line|
        CSV.open('./weekly-summary/weekly-summary-totals.csv', 'a+') {|row| row << line}
      end
    end
  end
end

files = Dir.entries('./weekly-summary/').reject{|x| !x.include?('.PDF')}

files.each {|file| Parser.parse_files(file)}