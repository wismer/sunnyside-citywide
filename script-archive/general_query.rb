require 'prawn'
require 'csv'

module Parser
  def self.parse_page(page)
    client = page.split(/\n/).reject{|x| x !~ /^\(\s+WEEK/}.reject{|x| x.nil?}.map{|x| x = x[88..113].strip}[0]
    data   = page.split(/\n/).reject{|x| x !~ /^\(\s+\:/}
    report = Report.new(client, data)
    report.parse_data
    report.show_data
  end

  class Report
    def initialize(client, data)
      @client, @data = client, data
    end

    def parse_data
      @data.map! do |line|
        line = { 
                   dos: line[/[0-9\/]{8}/],
          service_code: line[/[A-Z0-9]+(?=\:)/],
                  diag: line[/[A-Z0-9]+(?=\sF75)/],
                 rtype: line[/[A-Z0-9]+(?=\)')/],
                amount: line[/[\.0-9]+(?=\sHR|\sMU|\sLI)/]
        }
      end
    end

    def show_data

      @data.each do |line| 
        CSV.open('billing-edit-error.csv', 'a+') {|row| row << [@client, line[:dos], line[:service_code], line[:diag], line[:rtype], line[:amount]]}
      end
    end

    def to_csv
      
    end
  end
end
PDF::Reader.new('./archive/billing-edit-error/20130911_9075_B40.PDF').pages.each do |page|
  Parser.parse_page(page.raw_content)
end