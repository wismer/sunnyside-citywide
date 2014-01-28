module Sunnyside
  class Menu
    def start
      loop do 
        puts " 1.) LEDGER IMPORT" 
        puts " 2.) EDI IMPORT"
        puts " 3.) 837 IMPORT"
        puts " 4.) A/R REPORT"
        puts " 5.) CASH RECEIPT IMPORT"
        puts " 6.) ACCESS FTP"
        puts " 7.) EXPIRING AUTHORIZATION REPORT"
        puts " 9.) MCO - MLTC HOURS UPDATE"
        puts "10.) CUSTOM QUERY"
        puts "11.) ADD A NEW PROVIDER"
        puts "12.) VIEW DATABASE ON WEB BROWSER"
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
          Sunnyside.run_report
        when '5' 
          Sunnyside.cash_receipt
        when '6'
          Sunnyside.access_ftp
        when '7'
          Sunnyside.show_opts
        when '8'
          Sunnyside.process_private
        when '9'
          Sunnyside.run_mco_mltc
        when '10'
          Sunnyside.query
        when '11'
          Sunnyside.advanced_opts
        when '12'
          Sunnyside.rails_server
        else
          exit
        end
      end
    end
  end
end