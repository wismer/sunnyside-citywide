module Sunnyside
  OPTS = ['1.) By Client ID', '2.) By CHECK NUMBER', '3.) By PROVIDER NAME', '4.) by INVOICE NUMBER', '5.) EXIT']
  def self.select_opts
    puts OPTS
    res = gets.chomp
    report = 
      case res
      when '1' then Query.new(res, :client)
      when '2' then Query.new(res, :check)
      when '3' then Query.new(res, :provider)
      when '4' then Query.new(res, :invoice)
      when '5'
        exit
      else
        exit
      end
    report.show
  end

  class Query
    attr_reader :res, :opts
    def initialize(res, opts)
      @res = res
      @opts = opts
    end

    def show
      if :client
        puts 'symbol me this!'
      end
    end
  end
end