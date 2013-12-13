module Sunnyside
  class EraLibrary
    include Edi
    attr_reader :files

    def initialize
      @files = Dir["835/*.txt"].select { |file| Filelib.where(filename: file).count == 0 }
    end

    def formatted_data
      files.each { |file| 
        check, *claims = File.open(file).read.split(/~(?=CLP)/) 
        yield EdiCheck.new(check, claims)
      }
    end

    def parse
      formatted_data do |chk|
        puts chk.check
      end
    end

    class EdiCheck
      attr_reader :check, :claims
      def initialize(check, claims)
        @check_number = check[/(?<=~TRN\*\d\*)\w+/]
        @check_total  = check[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
        @type         = check[/(?<=\*C\*)(CHK|ACH)/, 1]
        @claims       = claims
      end

      def show
        puts check[/(?<=~TRN\*\d\*)\w+/]
      end
    end

    class EraClaims

    end

  end
end




#     def check_type_and_number
#       if header[/(?<=\*C\*)ACH/] == 'ACH'
#         check_number = header[/(?<=~TRN\*\w\*)\w+/]
#         check_amount = header[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
#       elsif header[/(?<=\*C\*)CHK/] == 'CHK'
#         check_number = header[/(?<=~TRN\*\d\*)\d+/]
#         check_amount = header[/(?<=~BPR\*\w\*)[0-9\.\-]+/]
#       else
#         check_number = 0
#         check_amount = 0.0
#       end
#       find_claims(check_number, check_amount)
#     end

#     def find_claims(check_number, check_amount)
#       claims.map! { |clm| ClaimParser.new(check_number, check_amount, clm) }
#     end

#     def sort_claims
#       claims.each { |clm| clm.identify_parts }
#     end
#   end

#   class ClaimParser < EraLibrary
#     attr_reader :claim
#     def initialize(check_number, check_amount, claim)
#       @check_number = check_number
#       @check_amount = check_amount
#       @claim        = claim
#     end

#     def identify_parts
#       data = claim.split(/~SVC/).map {|section|
#         section = if section =~ /^[0O\d]/ 
#                     ClaimHeader.new(section).sort_header
#                   else
#                     ClaimBody.new(section)
#                   end
#       }
#     end

#     def to_s
#       # "#{claim}"
#     end
#   end

#   class ClaimHeader < EraLibrary
#     attr_reader :claim_header

#     def initialize(claim_header)
#       @claim_header = claim_header.split(/~/).reject {|x| x=~/^DTM/}
#     end

#     def sort_header
#       claim_header.map{|section|
#         if section =~ /^NM1\*QC/
#           section = section.gsub(/^NM1\*QC\*\d\*/, '')
#           create_client_data(section)
#         else
#           # InvoiceData.new(section)
#         end 
#       }
#       # puts "#{claim_header}"
#     end


#     def create_client_data(section)
#       first_name, last_name = sectio
#     end
#   end

#   class ClaimBody < EraLibrary
#     def initialize(claim_body)
#       @claim_body = claim_body
#     end
#   end

#   class ClientData < EraLibrary
#     def initialize(line)
#       @first, @last, @initial, @recipient_id = line
#     end

#     def method_name
      
#     end
#   end

#   class InvoiceData < EraLibrary
#   end
# end