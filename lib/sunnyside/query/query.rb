# definitely a work in progress.

module Sunnyside

  class Query
    attr_reader :client
    def initialize
  
    end

    def ans
      gets.chomp
    end

    def search_by_client
      print 'Enter in the SANDATA ID client number for this client: '
      @client = Client[ans]
      if client
        client_opts
      else
        puts 'invalid client number. Please re-enter.'
        search_by_client
      end
    end

    def client_opts
      puts "You've selected #{client.client_name}. How do you wish to proceed? "
      puts "1.) View invoices "
      puts "2.) View visits   "
      puts "3.) View claims   "
      case ans
      when '1'
        view_invoices
      when '2'
        select_visits
      when '3'
        view_claims
      else
        break
      end      
    end

    def view_invoices

    end

    def select_visits
      puts  'Type in the date range (use YYYY-MM-DD format)'
      print 'Start Date: '
      start_date = Date.parse(ans)
      print 'End Date:   '
      end_date   = Date.parse(ans)
      if client
        visits        = Visit.where(client_id: client.client_number, dos: start_date..end_date).order(:dos) 
        record_limit  = 30
        record_offset = 0
        visits.count.times do 
          view_visits
        end
      end
    end

    def view_visits(visits)
      puts "Hit enter to view next set of 30 visits. To go back, type 'back'."
      record_limit  = 30
      record_offset = 0
      
      case ans
      when ''
        visits.limit(record_limit).offset(record_offset).all.each { |visit| show(visit) }
        limit += 30
      end
    end

    def show(line)
      if line.class == Visit
        puts "#{line.invoice_id} #{line.dos} #{line.service_code} #{line.modifier} #{line.amount} #{line.units}"
      end
    end

    def view_claims
      
    end
  end
end