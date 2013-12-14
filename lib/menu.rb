module Sunnyside
  class Menu
    def start
      loop do 
        puts "1.) LEDGER IMPORT"
        puts "2.) EDI IMPORT"
        puts "3.) 837 IMPORT"
        puts "4.) A/R REPORT"
        puts "5.) CASH RECEIPT IMPORT"
        puts "6.) CUSTOM SEARCH"
        puts "7.) EXPIRING AUTHORIZATION REPORT"
        puts "8.) EXIT"
        puts "select option: "
        case gets.chomp
        when '1' 
          Sunnyside::ledger_file
          Sunnyside.process_private
        when '2' 
          edi = Sunnyside::EraLibrary.new
          edi.parse
        when '3'
          Sunnyside.parse_pdf
        when '4' 
          report = Sunnyside::Report.new
        when '5' 
          Sunnyside::CashReceipt.new.process
        when '6'
          rep = Sunnyside::Reporter.new
          rep.check_existing
        when '7'
          Sunnyside.show_opts
        when '8'
          Sunnyside.process_private
        else
          exit
        end
      end
    end
  end
end