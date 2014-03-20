# definitely a work in progress.

module Sunnyside

  def self.query
    puts "1.) VIEW CLIENTS BY PROVIDER"
    puts "2.) "
    case gets.chomp
    when '1'
      Provder.all.each { |prov| puts "#{prov.id}: #{prov.name}"}
      print "Type in the provider ID number: "
      provider = Provider[gets.chomp]
      query = Query.new(provider)
      query.show_options
      # puts 'Type in post date (YYYY-MM-DD)'
      # date = Date.parse(gets.chomp)
      # if date.is_a?(Date)
      #   Invoice.where(post_date: date).all.each { |invoice| Sunnyside.payable_csv(invoice, date) }
      # end
    end
  end

  class Query
    attr_reader :type
    include Sunnyside

    def initialize(type)
      @type = type
    end

    def show_options
      if type.is_a?(Provider)
      end
    end

    def primary_id
    end

    def ledger_file
      puts 'Type in post date (YYYY-MM-DD)'
      date = Date.parse(gets.chomp)
      if date.is_a?(Date)
        Invoice.where(post_date: date).all.each { |invoice| self.payable_csv(invoice, date) }
      end
    end
  end
end