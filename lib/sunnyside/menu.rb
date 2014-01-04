module Sunnyside
  class Menu
    def start
      loop do 
        puts " 1.) LEDGER IMPORT #{new_files(:ledger)} new files" 
        puts " 2.) EDI IMPORT #{new_files(:edi)} new files"
        puts " 3.) 837 IMPORT #{new_files(:detail)} new files"
        puts " 4.) A/R REPORT"
        puts " 5.) CASH RECEIPT IMPORT"
        puts " 6.) ACCESS FTP"
        puts " 7.) EXPIRING AUTHORIZATION REPORT"
        puts " 9.) MCO - MLTC HOURS UPDATE"
        puts "10.) CUSTOM QUERY"
        print "select option: "
        case gets.chomp
        when '1' 
          Sunnyside.ledger_file
          Sunnyside.process_private
        when '2' 
          Sunnyside.edi_parser
        when '3'
          Sunnyside.parse_pdf
        when '4' 
          Sunnyside::Report.new
        when '5' 
          Sunnyside.cash_receipt
        when '6'
          Sunnyside.access_ftp(:download)
          Sunnyside.access_ftp(:upload)
        when '7'
          Sunnyside.show_opts
        when '8'
          Sunnyside.process_private
        when '9'
          Sunnyside.run_mco_mltc
        when '10'
          Sunnyside.query
        else
          exit
        end
      end
    end

    def new_files(type)
      if type == :ledger
        Dir["#{DRIVE}/sunnyside-files/summary/*.PDF", "#{DRIVE}/sunnyside-files/summary/*.pdf"].size
      elsif type == :edi
        Dir["#{DRIVE}/sunnyside-files/edi/*.txt"].size
      else
        Dir["#{DRIVE}/sunnyside-files/837/*.PDF", "#{DRIVE}/sunnyside-files/837/*.pdf"].size
      end
    end
  end
end