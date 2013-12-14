# require_relative '835_manip.rb'
# require_relative 'import.rb'
require_relative 'database.rb'
# files = Dir.entries('./835/').reject{|file| !file.include?('.txt')}
# files.each_with_index do |file, index|
#   Parser.get_check_title(file) {|title, date| print "#{index}.) #{title} #{file[/\S+/]}\n"}
# end
# print "\n\nSELECT THE FILE YOU WISH TO PROCESS:\n\n"
# response = gets.chomp
# Parser.open_file(files[response.to_i])

# files = Dir.entries('./835/').reject{|file| !file.include?('.txt')}
# files.each_with_index do |file, index|
#   print "processing: #{file}...\n"
#   Parser.open_file(file)  
# end
#   Parser.get_check_title(file) {|check, provider| print "#{index}.) #{provider} #{check}\n"}
# end
# print "\n\nSELECT THE FILE YOU WISH TO PROCESS:\n\n"
# response = gets.chomp
# Parser.open_file(files[response.to_i])


# checks = [95000138958, 98000004426, 90000254977, 95000139281, 98000004514, 90000257024, 95000144881, 98000004598, 90000258374, 95000146431, 9800004687, 90000261761, 95000147787, 98000004770, 90000263144, 95000148104, 9800004865, 90000266197]
loop do
  print "SELECT MENU OPTION: \n"
  print "   1.) ENTER IN EDI PAYMENTS\n"
  print "   2.) QUERY ERRORS/DENIALS\n"
  print "   3.) EXIT\n"
  response = gets.chomp
  if response == '1'
    loop do 
      print "\n   enter check number: "
      check = gets.chomp
      print "\nenter check post date: "
      post_date = gets.chomp
      invoices = Parser::DB[:invoices].where(check: check .to_i).map(:invoice_number)
      CSV.open("EDI-MISC-citywide-import.csv", "a+") {|row| row << ['Seq','Receipt','post_date','other id','invoice','header memo','batch','doc date','detail memo','fund','account','cc1','cc2','cc3','debit','credit']}
      total = 0.0
      invoices.each do |inv|
        Parser.add_invoice(inv) do |line|
          prov = Parser.check_provider(line.provider)
          print "#{line.client_name}: #{line.invoice_number} - #{line.invoice_amount} #{line.provider} -> SUBTOTAL: #{total+=line.amt_paid}\n"
          Parser.to_csv(line, prov, check, post_date)
        end
      end
    end
  elsif response == '2'
    loop do
      print "THE FOLLOWING CHECKS EXIST IN THE DB: \n"
      checks = Parser::DB[:invoices].exclude(check: nil).map(:check).uniq
      checks.each_with_index do |file, index|
        print "#{index}.) #{file}\n"
      end
      print "ENTER IN THE CHECK NUMBER FOR ERROR QUERY: \n"
      check = gets.chomp
      invoices = Parser::DB[:invoices].where(check: check.to_i).map(:invoice_number)
    end
  end
end

# # invs = [
#   250062,
#   250052,
#   250061,
#   168862,
#   168862,
#   250051,
#   250056,
#   250968,
#   250060,
#   250055,
#   250967,
#   250057,
#   185251,
#   185251,
#   184528,
#   185251,
#   184528,
#   185251,
#   185989,
#   185989,
#   190133,
#   190133,
#   191098,
#   191098,
#   250053,
#   175092,
#   175092,
#   250059
# ]

# puts invs.length
# invs.reject {|invoice| !Parser::DB[:invoices].where(invoice_number: invoice).all.empty?}.each {|x| 
  
# }