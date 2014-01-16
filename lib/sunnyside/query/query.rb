# definitely a work in progress.

module Sunnyside

  def self.query
    puts "1.) Rerun Ledger/CSV file creation"
    case gets.chomp
    when '1'
      Query.new.ledger_file
      # puts 'Type in post date (YYYY-MM-DD)'
      # date = Date.parse(gets.chomp)
      # if date.is_a?(Date)
      #   Invoice.where(post_date: date).all.each { |invoice| Sunnyside.payable_csv(invoice, date) }
      # end
    end
  end

  class Query
    include Sunnyside

    def ledger_file
      puts 'Type in post date (YYYY-MM-DD)'
      date = Date.parse(gets.chomp)
      if date.is_a?(Date)
        Invoice.where(post_date: date).all.each { |invoice| self.payable_csv(invoice, date) }
      end
    end
  end
end