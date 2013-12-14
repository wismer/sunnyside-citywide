module Sunnyside
  def self.show_opts
    print "Which auth report are you reporting? (type 'prior' for prior report, auth-by-service-code report, use 'code': "
    ans = gets.chomp.downcase
    if ans == 'prior'
      print "type file name now (must be saved in /archive/auth folder): "
      Sunnyside.parse_prior_file(gets.chomp)
    elsif ans == 'code'
      print "type file name now (must be saved in /archive/auth folder): "
      Sunnyside.parse_code_file(gets.chomp)
    else
      Sunnyside.show_opts
    end
  end

  def self.parse_code_file(file)
    PDF::Reader.new('./archive/auth/'+file).pages.each do |page|
      provider = page.raw_content[/Provider\s(\S+)/]
      code = CodeList.new(provider, page.raw_content)
      if provider
        code.provider_format
        code.code_format
        code.parse_clients
      end
    end
  end

  def self.parse_prior_file(file)
    PDF::Reader.new('./archive/auth/'+file).pages.each do |page|
      provider = page.raw_content.split(/\n/).reject{|x| !x.include?('CONTRACT: 0')}.join.gsub(/^\(CONTRACT\:\s\d+\s+|\)'/, '')
      auth = AuthList.new(provider, page.raw_content)
      print "#{provider}\n"
      if provider
        # auth.code_format
        # auth.parse_clients
      end
    end
  end
  class 
    def initialize(provider, data)
      @provider, @data = provider, data
      @clients = {}
    end

    def code_format
      @code = @data[/Procedure\s(T1019|M1019|99082|S5130|S5125|S5131|S5126|T1020|T1001|T1030|H1019|M5125)\s*(1C|TT)?/].strip.gsub(/Procedure/, '')
    end

    def parse_clients
      @data.split(/\n/).map{|x| x.gsub(/^\(\s+|\)'$/, '')}.reject{|x| !x.include?(',')}.each{|client| parse_client(client)}
    end

    def parse_client(client_line)
      client_line.scan(/^(.{30})\s+(\d+)\s+(\d+)\s+\d+\s+\S\s+([0-9A-Z\-]+)\s+\S\s+([0-9\/]+)?\s*([0-9\/]+)?/) do |line|
        client = PriorAuth.new(line)
        client.date_format
        client.to_csv(@provider, @code)
      end
    end
    def initialize(line, auth=nil)
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

  class AuthList
    def initialize(provider, data)
      @provider, @data = provider, data
    end
  end

  class Service < Sequel::Model; end
  class Authorization < Sequel::Model; end
end