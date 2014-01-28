module Sunnyside
  def self.advanced_opts
    puts "1.) Add new provider"
    puts "2.) Export A/R denials"

    case gets.chomp
    when '1'
      print "Type in the provider name _EXACTLY_ how it appears on the SanData archive report files (e.g. Guildnet is always GUILDNET): "
      provider = gets.chomp
      print "Now type in the abbreviation (batch initials - e.g. MetroPlus Health is MPH): "
      abbrev   = gets.chomp
      print "Now type in the CREDIT account that is used in FUND EZ: "
      credit = gets.chomp
      print "Now type in the DEBIT account that is used in FUND EZ: "
      debit  = gets.chomp
      print "And finally, type in the FUND number that is used in FUND EZ: "
      fund   = gets.chomp
      puts "---------------------------------------------------"
      puts "--------Please review the below information--------"
      puts ""
      puts "Name: #{provider}, Credit Account: #{credit}, Debit Account: #{debit}, Fund: #{fund}, Abbreviation: #{abbrev}"
      puts ""
      puts "---------------------------------------------------"
      print "Is this correct? (Y for yes, N for No): "
      if gets.chomp == 'Y'
        provider = Provider.insert(name: provider, credit_account: credit, debit_account: debit, fund: fund, abbreviation: abbrev)
        puts "#{Provider[provider].name} added."
      else
        Sunnyside.advanced_opts
      end
    else
      exit
    end
  end

  def self.rails_server
    Dir.chdir("#{DRIVE}/sunnyside-files/sunnyside-app")
    puts "Open your web browser and type in this in the address bar (and then press enter): http://localhost:3000/providers"
    puts "Please wait..."
    %x(start /max http://localhost:3000/providers)
    %x(rails s)
    Dir.chdir("#{DRIVE}/Program Files/Mozilla Firefox")
  end
end