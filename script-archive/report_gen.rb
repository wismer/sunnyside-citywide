require 'csv'
require 'sequel'


DB = Sequel.connect('sqlite://citywide-db.db')

# DB.create_table(:reports) do
#   primary_key :id
#   String      :filename
#   String      :file_extension
#   String      :file_type
#   Date        :date_processed
#   String      :root_folder
# end
module Parser
  DB = Sequel.connect('sqlite://citywide-db.db')

  def self.process_file(file, type)
    if Report.where(filename: file).get(:id).nil?
      Report.insert(filename: file, file_extension: File.extname(file), file_type: type, date_processed: Time.now, root_folder: File.absolute_path(file))  
    end
      Parser.parse_file(file, type)    
  end

  def self.parse_file(file, type)
    File.open('./837/ftp/'+file).read.split(/\n/).map{|x| x.strip!.gsub(/\|/, ' ')}.each{|data| Parser.set_vars(data, type)}
  end

  def self.set_vars(data, type)
    if type == '837 Header'  
      data.scan(/^(\d+)?.+(?<=\s)([0-9]+)(?=SUP)/) do |line|
        puts Service.where(client_identifier: line[0]).get(:service_code)
        Service.where(client_identifier: line[0]).update(invoice_number: line[1][0..5].to_i)
      end
    end
    # else
    #   data.scan(/^(\d+)\s\d+\s+(\S+)\s+(\S+)?\s(\S+)?\s+(\d+)\s(\S+)\s(\S+)/) do |line|
    #     line[4], line[5], line[6] = Date.parse(line[4]), line[5].to_f, line[6].to_f
    #     Service.insert(client_identifier: line[0], service_code: line[1], modifier: line[2], modifier1: line[3], dos: line[4], units: line[5], amount: line[6])
    #   end
    # end
  end

  def self.match_invoices(invoice, client_name)
    print "#{invoice} #{client_name}\n"
    Service.where(invoice_number: invoice).update(client_name: client_name)
  end
  class Report < Sequel::Model; end
  class Service < Sequel::Model; end
  class Invoice < Sequel::Model; end
end

DB[:invoices].to_hash(:invoice_number, :client_name).each {|inv, client| Parser.match_invoices(inv, client)}

# files = Dir.entries('./837/ftp/').reject{|file| !file.include?('SUPINST')}
# files.each do |file|
#   print "processing #{file}...\n"
#   # Parser.process_file(file, '837 Detail') if file.include?('D')
#   Parser.process_file(file, '837 Header')
# end