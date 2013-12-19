module Sunnyside
  class << self
    def create_tables
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
        String        :client_name
        Float         :rate
        Float         :hours
      end

      DB.create_table :payments do 
        primary_key   :id 
        foreign_key   :provider_id, :providers
        foreign_key   :filelib_id, :filelibs
        Float         :check_total
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
      end

      DB.create_table :providers do 
        primary_key   :id
        Integer       :credit_account
        Integer       :fund 
        Integer       :debit_account
        String        :name
        String        :abbreviation
        String        :type
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