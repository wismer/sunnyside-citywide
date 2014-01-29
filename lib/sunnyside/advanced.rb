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
      review = "--------Name: #{provider}, Credit Account: #{credit}, Debit Account: #{debit}, Fund: #{fund}, Abbreviation: #{abbrev}--------"
      puts "Please review the below information."
      puts '-' * review.length
      puts review
      puts '-' * review.length
      print "Is this correct? (Y for yes, N for No): "
      raise 'You have an empty field! Start over!' if [provider, credit, debit, fund, abbrev].any? { |elem| elem.empty? }
      if gets.chomp.upcase == 'Y'
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
    puts "Please wait..."
    Sunnyside.determine_browser

    %x(start /max http://localhost:3000/providers)

    puts "Web browser launched. Now launching server..."

    Dir.chdir("#{DRIVE}/sunnyside-files/sunnyside-app")

    %x(rails s)
  end

  def self.determine_browser
    if Dir.exist?("#{DRIVE}/Program Files (x86)")
      Dir.chdir("#{DRIVE}/Program Files (x86)/Mozilla Firefox")
    else
      Dir.chdir("#{DRIVE}/Program Files/Mozilla Firefox")
    end
  end

  def self.add_provider_to_ftp
    Provider.all.each { |prov| puts "#{prov.id}: #{prov.name}"}
    print "Type in the corresponding ID Number for the provider you would like to add to FTP: "
    
    provider = Provider[gets.chomp].abbreviation
    
    puts "You've selected #{provider}"

    print "Type in the ftp address now: "
    site = gets.chomp

    print "Type in the username now: "
    username = gets.chomp

    print "Type in the password now: "
    password = gets.chomp

    review = "-------Provider: #{provider}, Site: #{site}, Username: #{username}, Password: #{password}--------------"
    puts "Please review the following information: "
    puts '-' * review.length
    puts review
    puts '-' * review.length

    puts "Is this correct? Type Y or N."
    if gets.chomp.downcase == 'y'
      Login.insert(site: site, username: username, password: password, provider: provider)
      Dir.mkdir("#{DRIVE}/sunnyside-files/ftp/835/#{provider}")
      Dir.mkdir("#{DRIVE}/sunnyside-files/ftp/837/#{provider}")
    else
      puts 'Please try again.'
      Sunnyside.add_provider_to_ftp
    end
  end
end