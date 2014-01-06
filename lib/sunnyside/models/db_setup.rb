module Sunnyside

  class << self

    def create_folders
      folders     = ['db', '835', '837', 'summary', 'cash_receipts', 'new-ledger', 'private', 'private/archive', 'summary/archive', '837/archive', '835/archive']
      Dir.mkdir("#{DRIVE}/sunnyside-files")
      folders.each { |folder| Dir.mkdir("#{DRIVE}/sunnyside-files/#{folder}") }
    end

    def create_tables
      DB.create_table :logins do 
        primary_key :id
        String      :site
        String      :username
        String      :password
        String      :provider
      end

      DB.create_table :charges do 
        primary_key   :id
        foreign_key   :invoice_id, :invoices
        foreign_key   :provider_id, :providers
        Date          :dos
        Float         :amount
        Float         :units
        String        :service_code
        String        :filename
      end

      DB.create_table :invoices do 
        Integer       :invoice_number, :primary_key=>true
        index         :invoice_number
        Float         :amount
        Date          :post_date, :default=>Date.today
        foreign_key   :client_id, :clients
        foreign_key   :provider_id, :providers
        foreign_key   :filelib_id, :filelibs
        Integer       :service_number
        String        :auth
        String        :client_name
        Float         :rate
        Float         :hours
        String        :recipient_id
      end

      DB.create_table :payments do 
        primary_key   :id 
        foreign_key   :provider_id, :providers
        foreign_key   :filelib_id, :filelibs
        Float         :check_total
        Date          :post_date, :default=>Date.today
        String        :status
        Integer       :check_number
      end

      DB.create_table :claims do 
        primary_key   :id
        index         :id
        String        :control_number
        foreign_key   :payment_id, :payments
        foreign_key   :invoice_id, :invoices
        foreign_key   :client_id, :clients
        Float         :paid 
        Float         :billed
        String        :status
        String        :recipient_id
        foreign_key   :provider_id, :providers
        Date          :post_date
      end

      DB.create_table :services do 
        primary_key   :id
        foreign_key   :claim_id, :claims
        foreign_key   :payment_id, :payments
        foreign_key   :invoice_id, :invoices
        foreign_key   :client_id, :clients
        String        :service_code
        Float         :paid
        Float         :billed
        String        :denial_reason
        Float         :units
        Date          :dos
      end

      DB.create_table :clients do
        Integer       :client_number, :primary_key=>true
        String        :client_name
        String        :fund_id
        String        :recipient_id
        foreign_key   :provider_id, :providers
        String        :prov_type, :default=>'MLTC'
        Date          :dob
      end

      DB.create_table :providers do 
        primary_key   :id
        Integer       :credit_account
        Integer       :fund 
        Integer       :debit_account
        String        :name
        String        :abbreviation
        String        :prov_type
        String        :edi_identifier
      end

      DB.create_table :filelibs do
        primary_key   :id
        String        :filename
        String        :purpose
        String        :file_type
        Time          :created_at
      end

      DB.create_table :visits do 
        primary_key :id
        String      :service_code
        String      :modifier
        foreign_key :invoice_id, :invoices
        foreign_key :client_id, :clients
        Float       :amount
        Float       :units
        Date        :dos
      end

      DB.create_table :denials do 
        primary_key :denial_code, :primary_key=>true
        String      :denial_explanation
      end
      
      DB.create_table :authorizations do 
        primary_key :id
        String      :auth
        foreign_key :client_id, :clients
        Integer     :service_id
        Date        :start_date
        Date        :end_date
      end
    end

    def add_denial_data
      CSV.foreach('examples/denial_data.csv', 'r') { |row| Denial.insert(denial_code: row[1], denial_explanation: row[2]) }
    end

    def add_providers
      DB[:providers].insert(:credit_account=>1206, :fund=>500, :debit_account=>5005, :name=>"AMERIGROUP 2", :abbreviation=>"AMG", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1207, :fund=>300, :debit_account=>5007, :name=>"CHILDREN'S AID SOCIETY", :abbreviation=>"CAS", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1226, :fund=>300, :debit_account=>5026, :name=>"COMPREHENSIVE CARE MANAGEMENT", :abbreviation=>"CCM", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1203, :fund=>300, :debit_account=>5002, :name=>"DOMINICAN SISTERS FAM HLTH", :abbreviation=>"DSF", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1209, :fund=>300, :debit_account=>5009, :name=>"ELDERSERVE HEALTH", :abbreviation=>"ELD", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1212, :fund=>300, :debit_account=>5012, :name=>"EMBLEM HEALTH", :abbreviation=>"EMB", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1201, :fund=>300, :debit_account=>5001, :name=>"GUILDNET", :abbreviation=>"G", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1227, :fund=>500, :debit_account=>5027, :name=>"HEALTH CARE PARTNERS", :abbreviation=>"HCP", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1218, :fund=>500, :debit_account=>5018, :name=>"HEALTH FIRST", :abbreviation=>"HFS", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1216, :fund=>500, :debit_account=>5016, :name=>"HEALTH INSURANCE PLAN OF NY", :abbreviation=>"HIP", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1223, :fund=>300, :debit_account=>5023, :name=>"HHH LONG TERM HOME HLTH CARE", :abbreviation=>"HHH", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1228, :fund=>300, :debit_account=>5028, :name=>"INDEPENDENCE CARE SYSTEMS", :abbreviation=>"ICS", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1217, :fund=>500, :debit_account=>5017, :name=>"METROPLUS HEALTH", :abbreviation=>"MPH", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1219, :fund=>500, :debit_account=>5019, :name=>"NEIGHBORHOOD HEALTH PROVIDERS", :abbreviation=>"NHP", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1221, :fund=>500, :debit_account=>5021, :name=>"NYS CATHOLIC/FIDELIS", :abbreviation=>"FID", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1200, :fund=>300, :debit_account=>5000, :name=>"PRIVATE", :abbreviation=>"P", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1204, :fund=>300, :debit_account=>5004, :name=>"SENIOR HEALTH PARTNERS", :abbreviation=>"SHP", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1202, :fund=>300, :debit_account=>5003, :name=>"SUNNYSIDE COMMUNITY SERVICES", :abbreviation=>"SCS", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1213, :fund=>500, :debit_account=>5013, :name=>"UNITED HEALTH CARE", :abbreviation=>"UHC", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1229, :fund=>500, :debit_account=>5029, :name=>"VNSNY CHOICE SELECT HEALTH", :abbreviation=>"VCS", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1224, :fund=>500, :debit_account=>5024, :name=>"WELCARE OF NEW YORK, INC.", :abbreviation=>"WEL", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1310, :fund=>300, :debit_account=>5030, :name=>"VILLAGE CARE MAX", :abbreviation=>"VIL", :prov_type=>"MLTC")
      DB[:providers].insert(:credit_account=>1222, :fund=>500, :debit_account=>5022, :name=>"AFFINITY HEALTH PLUS", :abbreviation=>"AFF", :prov_type=>"MCO")
      DB[:providers].insert(:credit_account=>1218, :fund=>500, :debit_account=>5018, :name=>"HEALTH PLUS PHSP,INC", :abbreviation=>"HFS", :prov_type=>"MCO")
    end
  end
end

# DB[:denials].insert(denial_code: 1, denial_explanation: 'not implemented yet')
# DB[:denials].insert(denial_code: 96, denial_explanation: "NO AUTHORIZATION FOR DOS")
# DB[:denials].insert(denial_code: 197, denial_explanation: "Precertification/authorization/notification absent")
# DB[:denials].insert(denial_code: 198, denial_explanation: "Precertification/authorization exceeded")
# DB[:denials].insert(denial_code: 199, denial_explanation: "Revenue code and Procedure code do not match")
# DB[:denials].insert(denial_code: 9, denial_explanation: "DIAGNOSIS ISSUE")
# DB[:denials].insert(denial_code: 15, denial_explanation: "AUTHORIZATION MISSING/INVALID")
# DB[:denials].insert (denial_code: 18, denial_explanation: "Exact Duplicate Claim/Service")
# DB[:denials].insert(denial_code: 19, denial_explanation: "Expenses incurred prior to coverage")
# DB[:denials].insert(denial_code: 27, denial_explanation: "Expenses incurred after coverage terminated")
# DB[:denials].insert(denial_code: 29, denial_explanation: "Timely Filing")
# DB[:denials].insert(denial_code: 39, denial_explanation: "Services denied at the time authorization/pre-certification was requested")
# DB[:denials].insert(denial_code: 45, denial_explanation: "Charge exceeds fee schedule/maximum allowable")
# DB[:denials].insert(denial_code: 16, denial_explanation: "Claim/service lacks information which is needed for adjudication")
# DB[:denials].insert(denial_code: 50, denial_explanation: "These are non-covered services because this is not deemed a 'medical necessity' by the payer")
# DB[:denials].insert(denial_code: 192, denial_explanation: "Non standard adjustment code from paper remittance")
# DB[:denials].insert(denial_code: 181, denial_explanation: "Procedure code was invalid on the date of service")
# DB[:denials].insert(denial_code: 182, denial_explanation: "Procedure modifier was invalid on the date of service")
# DB[:denials].insert(denial_code: 204, denial_explanation: "This service/equipment/drug is not covered under the patients current benefit plan")
# DB[:denials].insert(denial_code: 151, denial_explanation: "151 Payment adjusted because the payer deems the information submitted does not support this many/frequency of services")
# DB[:denials].insert(denial_code: 177, denial_explanation: "Patient has not met the required eligibility requirements")
# DB[:denials].insert(denial_code: 109, denial_explanation: "Claim/service not covered by this payer/contractor. You must send the claim/service to the correct payer/contractor.")