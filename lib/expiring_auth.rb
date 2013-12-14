module Sunnyside
  def self.expiring_auth
    Dir["data/exp auth/*.txt"].each do |file|
      file = File.open(file)
      data = file.read.split("\n").reject { |line| line =~ /\f/}
      data.each { |line| 
        if line =~ /^.{27}\d{7}\s+\d{7}\s/
          client = line.slice!(0..26)
          line   = line.split(' ').keep_if { |elem| elem.length >= 4 }
          data   = ExpiringAuth.new(file, client, line)
          print "#{line}\n"
        end
      }
      file.close
      FileUtils.mv(file, "data/exp auth/previous/#{File.basename(file)}")
    end
    clients = Authorization.map(:client_number).uniq
    clients.each { |client| 
      most_recent_auth = Authorization.where(client_number: client).exclude(auth: 'Blanket').order(:end_date).last
      # that gets the most recent auth that isnt a blanket.
      # visits           = Visit.where(member_id: client).where('dos > ?', most_recent_auth.end_date) if !most_recent_auth.nil?
      # puts "#{client} #{visits.count}" if !visits.nil?
    #   that gets all the visits that has that particular client number that is also GREATER than the most_recent_auth's end date
      # client.each { |x| puts x.client }
      auth_data = Authorization.where(client_number: client)
      auth      = auth_data.order(:end_date).all.last
      AuthReport.new(auth_data, auth).create_csv
    }
  end

  class ExpiringAuth
    attr_reader :file, :line, :client_id, :auth, :start_date, :end_date, :service_id, :client

    def initialize(file, client, line)
      @file                                                  = file
      @client                                                = client.strip
      @service_id, @client_id, @auth, @start_date, @end_date = line
      if Authorization.where(auth: auth, client: client.strip).count == 0
        process
      end
    end

    def provider
      if invoice.count > 0
        invoice.all.last.provider
      else
        nil
      end
    end

    def invoice
      Invoice.where(service_number: client_id) || Invoice.where(service_number: service_id)
    end

    def process
      Authorization.insert(auth: auth, provider: provider, client: client, start_date: begin_date, end_date: final_date, client_number: client_id, service_number: service_id)
    end

    def begin_date
      if start_date.nil?
        Date.new
      else
        Date.strptime(start_date, '%m/%d/%y')
      end
    end

    def final_date
      if end_date.nil?
        Date.new
      else
        Date.strptime(end_date, '%m/%d/%y') 
      end
    end
  end

  class AuthReport
    attr_reader :client_auth, :invoices, :visits, :auth

    def initialize(client, auth)
      @auth   = auth
      @client_auth            = client
      @visits                 = Visit.where(member_id: client.get(:client_number)).all.select { |visit| auth.end_date < visit.dos }
    end

    def create_csv
      if expired?
        CSV.open('auth_report', 'a+') { |row| row << ['EXPIRED', auth.client, auth.provider, auth.start_date, auth.end_date, auth.auth] }
        if visits.count > 0
          # puts visits
          visits.each { |visit| CSV.open('auth_report', 'a+') { |row| row << [''       , visit.dos, visit.service_code, visit.units, visit.amount] } }
        end
      else
        CSV.open('auth_report', 'a+') { |row| row << ['PENDING', auth.client, auth.provider, auth.start_date, auth.end_date, auth.auth] }
      end
    end

    def expired?
      auth.end_date < Date.today
    end
  end
end