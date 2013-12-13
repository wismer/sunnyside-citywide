# Some clients have fund ids like 's' that needs fixing. Need summary by hours, as well. I really REALLY need to make spec tests

require 'sequel'
require 'prawn'
require 'csv'
require 'date'
module Sunnyside
  DB = Sequel.connect('sqlite://project.db')
  class Ledger
    def display_menu
      root_dir = Dir.entries('./summary/').reject{|file| file !~ /.pdf|.PDF/ || Filelib.map(:filename).include?(file)}.each{|file| process_file(file) } || []
      print "No files to process.\n" if root_dir.empty?
    end

    def parse_date(file)
      @post_date = Date.parse(file[0..7])
    end

    def process_file(file)
      parse_date(file)
      print "processing #{file}...\n"
      PDF::Reader.new("./summary/"+file).pages.each do |t| 
        provider = t.raw_content[/(?:ER\:\s+)(.+)(?=\)')/].gsub(/^ER\:\s+/, '') || 'error reading provider name'
        t.raw_content.split(/\n/).reject{|x| x !~ /^\([0-9\/\)]+\s/}.each {|line| parse_line(line.gsub(/[\(\)\']+/, ''), provider)} if !t.raw_content.include?('VISITING NURSE SERVICE')
      end
      Filelib.insert(filename: file, purpose: 'Ledger import', file_type: '.pdf', created_at: Time.now)
    end

    def parse_line(line, provider)
      provider = 'PRIVATE' if !Provider.map(:name).include?(provider)
      post_date, invoice, client, service_num, hours, rate, amount = line.match(/^([0-9\/]+)\s+(\d+)\s+(.{26})(\d+)\s+(\S+)\s+(\S+)\s+([0-9\.,]+)/).captures
      hours    = hours.to_f * 11 if client.strip == 'LUSKIND, FRANCES'
      Invoice.insert(invoice_number: invoice.to_i, client_name: client.strip, hours: hours, rate: rate.to_f, amount: amount.gsub(/,/, '').to_f, provider: provider, service_number: service_num.to_i, post_date: @post_date)
      add_client(client.strip, provider) if client?(client.strip)
    end

    def client?(client)
      Client.where(client_name: client).get(:client_name) != client
    end

    def add_client(client, provider)
      print "#{client} for #{provider} not in DB. Enter in the Fund-EZ ID for this client now. "
      Client.insert(client_name: client.strip, fund_id: gets.chomp)
    end

    def get_client_id(client_name)
      Client.where(client_name: client_name).get(:fund_id)
    end

    def invoice_hours(prov, post_date)
      Invoice.where(post_date: post_date, provider: prov).sum(:hours).round(2)
    end

    def summary
      print "Type in the post date (YYYY-MM-DD) to view summary and create csv: "
      post_date = gets.chomp
      Invoice.where(post_date: post_date).map(:provider).uniq.each {|prov| print "#{prov}: #{Invoice.where(provider: prov, post_date: post_date).sum(:amount).round(2)} ---- HOURS: #{invoice_hours(prov, post_date)}\n"}
      to_csv(post_date)
    end

    def to_csv(post_date)
      post_date = Date.strptime(post_date)
      week_end = post_date - 5
      CSV.open("./ledger-files/#{post_date}-IMPORT-FUND-EZ-LEDGER.csv", "a+") {|row| row << ["Seq","inv","post_date","other id","prov","invoice","header memo","batch","doc date","detail memo","fund","account","cc1","cc2","cc3","debit","credit"]}
      Invoice.where(post_date: "#{post_date}").all.each do |inv|
        fund_id = get_client_id(inv.client_name)
        match_provider(inv.provider) do |prov|
          prov.name = 'AMERIGROUP' if prov.name == 'AMERIGROUP 2'
          CSV.open("./ledger-files/#{post_date}-IMPORT-FUND-EZ-LEDGER.csv", "a+") do |row|
            row << [1, inv.invoice_number, post_date.strftime('%m/%d/%y'), fund_id, prov.name, post_date.strftime('%m/%d/%y'), "To Record #{post_date.strftime('%m/%d/%y')} Billing", "#{post_date.to_s[5..6]}/13#{prov.abbrev}", post_date.strftime('%m/%d/%y'), "To Rec for W/E #{week_end} Billing", prov.fund, prov.credit_acct,             '', '',                  '',inv.amount,                          '']
            row << [2, inv.invoice_number, post_date.strftime('%m/%d/%y'), fund_id, prov.name, post_date.strftime('%m/%d/%y'), "To Record #{post_date.strftime('%m/%d/%y')} Billing", "#{post_date.to_s[5..6]}/13#{prov.abbrev}", post_date.strftime('%m/%d/%y'), "To Rec for W/E #{week_end} Billing", prov.fund, prov.debit_acct,   prov.fund, '',      prov.type,                     '',     inv.amount]
          end
        end
      end
    end

    def match_provider(prov)
      Provider.where(name: prov).all.each {|prov| yield prov}
    end
  end

  class Invoice < Sequel::Model; end
  class Filelib < Sequel::Model; end
  class Payment < Sequel::Model; end
  class Claim < Sequel::Model; end
  class Client < Sequel::Model; end
  class Service < Sequel::Model; end
  class Provider < Sequel::Model; end
  class Charge < Sequel::Model; end
  class Authorization < Sequel::Model; end
end