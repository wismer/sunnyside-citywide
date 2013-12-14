require 'prawn'
require 'sequel'

DB = Sequel.connect('sqlite://citywide-db.db')
total = 0.0
PDF::Reader.new(ARGV[0]).pages.each do |page|
  if page.raw_content =~ /VISITING NURSE SERVICE/
    hours = page.raw_content.match(/^\(\d+\s+\S+\s+\S+\s+[A-Z, ]+([0-9\.]+)/).captures
    total += hours.join.to_f
  end
end
puts total.round(2)