require 'prawn'
require 'csv'
require 'sequel'
DB = Sequel.connect('sqlite://project.db')

module Sunnyside
  def self.parse_file(file)
    PDF::Reader.new('./archive/auth/'+file).pages.each do |page|
      provider = page.raw_content[/Provider\s(\S+)/]
      auth = Auth.new(provider, page.raw_content)
      unless provider.nil?
        auth.provider_format
        auth.code_format
        auth.parse_clients
      end
    end
  end
  class Auth
    def initialize(provider, data)
      @provider, @data = provider, data
      @clients = {}
    end

    def provider_format
      @provider.gsub!(/Provider\s/, '')
    end

    def code_format
      @code = @data[/Procedure\s(T1019|M1019|99082|S5130|S5125|S5131|S5126|T1020|T1001|T1030|H1019|M5125)\s*(1C|TT)?/].strip.gsub(/Procedure/, '')
    end

    def parse_clients
      @data.split(/\n/).map{|x| x.gsub(/^\(\s+|\)'$/, '')}.reject{|x| !x.include?(',') || x =~ /TOTAL|Provider/}.each{|client| parse_client(client)}
    end

    def parse_client(line)
      client = ClientList.new(line)
      client.date_format
      client.to_csv(@provider, @code)
    end
  end

  class ClientList < Auth
    def initialize(line)
      @client, @service_num, @start_date, @end_date = line.match(/^(.{30})(\d+)\s+.{34}(.{8})\s+(.{8})/).captures
    end

    def date_format
      @end_date   = Time.strptime(@end_date.gsub(/\s/, '0'), "%m/%d/%y")
      @start_date = Time.strptime(@start_date.gsub(/\s/, '0'), "%m/%d/%y")
    end

    def to_csv(provider, code)
      CSV.open('auth-list.csv', 'a+') {|row| row << [provider, @client.strip, @service_num, code, @start_date, @end_date]}
    end
  end
  class Service < Sequel::Model; end
  class Authorization < Sequel::Model; end
end

# Parser.match_with_fund_ez
# Parser.get_service_ids
# Parser.compare_dbs
Parser.parse_file('auth.PDF')
  # name, service_num, start_date, end_date = data.match(/^(.{30})(\d+)\s+(.{34})(.{8})\s+(.{8})/).captures
# Parser.match_val {|val| Service.where(service_id: val.service_num).update(auth_num: val.auth_num, end_date: val.end_date, start_date: val.start_date)}
parse = /\(.{28}(\d+)\s+\d+\s+\S+\s+\S\s+([0-9\-\/]+)\s+\d\s+(\S+)\s+(\S+)(?=\)')/ # service_num, client_num, auth, auth_start, auth_end