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
        # code.provider_format
        code.code_format
        code.parse_clients
      end
    end
  end

  def self.parse_prior_file(file)
    PDF::Reader.new('./archive/auth/'+file).pages.drop(1).each do |page|
      data = page.raw_content.split(/\n/).map{|line| line.gsub(/^\(|\)'$/, '')}.reject{|x| x !~ /^CONTRACT\:\s+\d|,/}
      # print "#{data}\n"
      if data
        auth = AuthList.new(data)
        auth.parse_provider
        auth.parse_clients {|cl| auth.parse_client(cl)}
      end
    end
  end

  class CodeList
    def initialize(provider, data)
      @provider, @data = provider, data
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

  class ClientList < CodeList
    def initialize(line)
      @client, @service_num, @start_date, @end_date = line.match(/^(.{30})(\d+)\s+.{34}(.{8})\s+(.{8})/).captures
    end

    def date_format
      @end_date   = Time.strptime(@end_date.gsub(/\s/, '0'), "%m/%d/%y")
      @start_date = Time.strptime(@start_date.gsub(/\s/, '0'), "%m/%d/%y")
    end

    def set_report
      Authorization.where(service_num: @service_num, start_date: @start_date, end_date: @end_date).get(:auth) || 'Blanket'
    end

    def to_csv(provider, code)
      CSV.open('auth-list.csv', 'a+') {|row| row << [provider, @client.strip, @service_num, code, @start_date, @end_date, set_report]}
    end
  end

  class AuthList
    def initialize(data)
      @data = data
    end

    def parse_provider
      @provider = @data[0].gsub(/^CONTRACT\:\s\d+\s+/, '')
    end

    def parse_clients
      @data.drop(1).each{|client| yield client}
    end

    def parse_client(client_line)
      client_line.scan(/^(.{26})\s+(\d+)\s+(\d+)\s+\d+\s+\S\s+([0-9A-Z\-\/]+)\s+\S\s+([0-9\/]+)?\s*([0-9\/]+)?/) do |line|
        client_prior, service_num, client_num, auth, start_date, end_date = line
        prior = List.new(client_prior, service_num, client_num, auth, start_date, end_date)
        prior.date_format
        prior.to_db(@provider)
      end
    end
  end

  class List < AuthList
    def initialize(client_prior, service_num, client_num, auth, start_date, end_date)
      @client_prior, @service_num, @client_num, @auth = client_prior, service_num, client_num, auth
      @start_date ||= start_date
      @end_date   ||= end_date
    end

    def date_format
      @end_date   = Time.strptime(@end_date, "%m/%d/%y") if @end_date
      @start_date = Time.strptime(@start_date, "%m/%d/%y") if @start_date
    end

    def to_db(provider)
      if (@end_date && @start_date).nil?
        Authorization.insert(client: @client_prior.strip, auth: @auth, has_blanket: 'Blanket', client_number: @client_num, service_num: @service_num, provider: provider)
      else
        Authorization.insert(client: @client_prior.strip, auth: @auth, start_date: @start_date, end_date: @end_date, client_number: @client_num, provider: provider, service_num: @service_num)
      end
    end
  end

  class Service < Sequel::Model; end
  class Authorization < Sequel::Model; end
end