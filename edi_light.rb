require 'date'
require 'pp'
module Sunnyside
  def self.edi_parser(edi_data)
    edi_data.gsub!(/\n/, '')
    edi_data = edi_data.split(/~CLP\*/)
    edi_file = EdiReader.new(edi_data)
    edi_file.parse_claims
  end

  class EdiReader
    attr_reader :edi_data

    def initialize(edi_data)
      @edi_data = edi_data
    end

    def claims
      edi_data.select { |clm| clm =~ /^\d+/ }.map { |clm| clm.split(/~(?=SVC)/) }
    end

    def check_number
      check = edi_data[0][/(?<=~TRN\*\d\*)\w+/]
      return check.include?('E') ? check[/\d+$/] : check
    end

    def check_total
      edi_data[0][/(?<=~BPR\*\w\*)[0-9\.\-]+/, 0]
    end

    def parse_claims
      payment_id = Payment.insert(check_number: check_number, check_total: check_total)
      claims.each { |claim| ClaimParser.new(claim, payment_id).parse }
    end
  end

  class ClaimParser < EdiReader
    attr_reader :claim_header, :service_data, :payment_id

    def initialize(claim, payment_id)
      @claim_header = claim[0].split(/\*/)
      @service_data = claim.select { |clm| clm =~ /^SVC/ }
    end

    def header
      {
        :invoice       => claim_header[0],
        :response_code => claim_header[1],
        :billed        => claim_header[2],
        :paid          => claim_header[3],
        :units         => claim_header[5], # 4 is not used - that is the patient responsibility amount
        :claim_number  => claim_header[6][/^\d+/]
      }
    end

    def parse
      claim    = ClaimEntry.new(header)
      claim_id = claim.to_db(payment_id)
      service_data.each { |service| ServiceParser.new(service, claim_id).parse }
    end
  end

  class ClaimEntry < EdiReader
    attr_reader :invoice, :response_code, :billed, :paid, :units, :claim_number

    def initialize(header = {})
      @invoice       = header[:invoice].gsub(/[OLD]/, 'O' => '0', 'D' => '8', 'L' => '1').gsub(/^0/, '')[0..5].to_i # for the corrupt SHP EDI files
      @response_code = header[:response_code]
      @billed        = header[:billed]
      @paid          = header[:paid]
      @units         = header[:units]
      @claim_number  = header[:claim_number]
    end

    def to_db(payment)
      Claim.insert(
        :invoice_id     => invoice,
        :payment_id     => payment,
        :control_number => claim_number,
        :paid           => paid,
        :billed         => billed,
        :status         => response_code
      )
      return Claim.id
    end
  end

  class ServiceParser < EdiReader
    attr_reader :service_line, :claim

    def initialize(service_line, claim_id)
      @service_line = service_line.split(/~/)
      @claim        = claim_id
    end

    def dos
      service_line.detect { |svc| svc =~ /^DTM/ }[/\w+$/]
    end

    def service_header
      line = service_line[0].split(/\*/).drop(1)
      if line.length == 7 || line[1] != line[2]
        return line.uniq
      else
        return line
      end
    end

    def error_codes
      service_line.find_all { |section| section =~ /^CAS|^SE/ }.map { |code| code[/\w+\*\w+\*(\d+)/, 1] }
    end

    def parse
      service = ServiceEntry.new(service_header, dos, error_codes)
      service.to_db(claim)
    end
  end

  class ServiceEntry < EdiReader
    attr_reader :paid, :billed, :service_code, :units, :res_code, :error_codes, :dos

    def initialize(service_header, dos, error_codes)
      @service_code, @billed, @paid, @res_code, @units = service_header
      @dos         = Date.parse(dos)
      @error_codes = error_codes.map { |id| Denial.new(id).reasons }
    end

    def to_db(claim)
      Service.insert(
        :claim_id      => claim,
        :denial_reason => denial_reason,
        :service_code  => service_code.gsub(/HC:/, ''),
        :paid          => paid,
        :billed        => billed,
        :units         => units,
        :dos           => dos
      )
    end

    def denial_reason
      error_codes.join("\n") if denied?
    end

    def denied?
      paid != billed
    end
  end

  class Payment
    def self.insert(data = {})
      puts "#{data} inserted!"
      return rand(100)
    end
  end

  class Claim
    def self.insert(data = {})
      puts "  #{data} inserted!"
    end

    def self.id
      rand(100)
    end
  end

  class Service
    def self.insert(data = {})
      puts "    #{data} inserted!"
    end
  end

  class Denial < EdiReader
    attr_reader :code
    def initialize(code)
      @code = code
    end

    def reasons
      case code.to_i
      when 197 then "Can't operate heavy machinery with an amputated limb.\n"
      when 85  then "Not tall enough to ride on roller coasters.\n"
      when 23  then "Unusually insane.\n"
      when 42  then "Inability to produce new content fast enough for his/her adoring fanbase.\n"
      else
        "Cool guy.\n"
      end
    end
  end
end
data = 'ISA*00*          *00*          *ZZ*11111111      *ZZ*56456132231      *131025*0639*U*00401
*006004035*0*P*:~GS*HP*11111111*56456132231*20131025*0639*1*X*004010X091A1~ST*835*0001~BPR*C*202.5
6*C*ACH*CTX*01*999999999*DA*999999999*4654314684**01*021000089*DA*213123123*20131024~TRN*1*2013061
9ERA256851223*5643215*99999~DTM*405*20131024~N1*PR*SOME PROVIDER*XV*231234342~N3*100 SOMEWHERE ST*
13TH FLOOR~N4*THIS CITY?*YES*10007~REF*2U*80141~N1*PE*THIS PLACE*FI*2314234423~N4*MY TOWN*NO*11104
~LX*1~CLP*8957515256*1*202.56*202.56**HM*0110031378121*12*1~NM1*QC*1*THE SWORDSMAN*BRONN****MI*YP3
4893V~NM1*IL*1*THE SWORDSMAN*BRONN****MI*PU23243G~NM1*82*1******FI*2314234423~DTM*232*20130923~DTM
*233*20130926~SVC*HC:T1019*50.64*50.64**12~DTM*472*20130923~REF*6R*1325288001~AMT*B6*50.64~SVC*HC:
T1019*50.64*50.64**12~DTM*472*20130924~REF*6R*1325288002~AMT*B6*50.64~SVC*HC:T1019*50.64*50.64**12
~DTM*472*20130925~REF*6R*1325288003~AMT*B6*50.64~SVC*HC:T1019*50.64*50.64**12~DTM*472*20130926~REF
*6R*1325288004~AMT*B6*50.64~LX*24~CLP*8957525256*4*405.12*0**HM*0110031378123*12*1~NM1*QC*1*LANNIS
TER*JAIME****MI*SB98419Y~NM1*IL*1*LANNISTER*JAIME****MI*PO23242K~NM1*82*1******FI*2314234423~DTM*2
32*20130924~DTM*233*20130927~SVC*HC:T1019*101.28*0****24~DTM*472*20130924~CAS*OA*197*101.28~CAS*OA
*1*101.28~REF*6R*1325290001~AMT*B6*101.28~SVC*HC:T1019*101.28*0****24~DTM*472*20130925~CAS*OA*197*
101.28~REF*6R*1325290002~AMT*B6*101.28~SVC*HC:T1019*101.28*0****24~DTM*472*20130926~CAS*OA*197*101
.28~REF*6R*1325290003~AMT*B6*101.28~SVC*HC:T1019*101.28*0****24~DTM*472*20130927~CAS*OA*197*101.28
~REF*6R*1325290004~AMT*B6*101.28~LX*25~CLP*8957535256*4*945.28*0**HM*0110031378126*12*1~NM1*QC*1*L
ANNISTER*CERSEI****MI*SC60317K~NM1*IL*1*LANNISTER*CERSEI****MI*PX2335423T~NM1*82*1******FI*2314234
423~DTM*232*20130921~DTM*233*20130927~SVC*HC:T1019*135.04*0****32~DTM*472*20130921~CAS*OA*23*135.0
4~REF*6R*1325293001~AMT*B6*135.04~SVC*HC:T1019*135.04*0****32~DTM*472*20130922~CAS*OA*23*135.04~RE
F*6R*1325293002~AMT*B6*135.04~SVC*HC:T1019*135.04*0****32~DTM*472*20130923~CAS*OA*23*135.04~REF*6R
*1325293003~AMT*B6*135.04~SVC*HC:T1019*135.04*0****32~DTM*472*20130924~CAS*OA*23*135.04~REF*6R*132
5293004~AMT*B6*135.04~SVC*HC:T1019*135.04*0****32~DTM*472*20130925~CAS*OA*23*135.04~REF*6R*1325293
005~AMT*B6*135.04~SVC*HC:T1019*135.04*0****32~DTM*472*20130926~CAS*OA*23*135.04~REF*6R*1325293006~
AMT*B6*135.04~SVC*HC:T1019*135.04*0****32~DTM*472*20130927~CAS*OA*23*135.04~REF*6R*1325293007~AMT*
B6*135.04~LX*26~CLP*8957545256*4*607.68*0**HM*0110031378132*12*1~NM1*QC*1*MARTIN*GEORGE*RR***MI*WF
19113P~NM1*IL*1*MARTIN*GEORGE*RR***MI*PO834762V~NM1*82*1******FI*2314234423~DTM*232*20130916~DTM*2
33*20130927~SVC*HC:T1019*67.52*0****16~DTM*472*20130916~CAS*OA*42*67.52~REF*6R*1325299001~AMT*B6*6
7.52~SVC*HC:T1019*67.52*0****16~DTM*472*20130917~CAS*OA*42*67.52~REF*6R*1325299002~AMT*B6*67.52~SV
C*HC:T1019*67.52*0****16~DTM*472*20130918~CAS*OA*42*67.52~REF*6R*1325299003~AMT*B6*67.52~SVC*HC:T1
019*67.52*0****16~DTM*472*20130919~CAS*OA*42*67.52~REF*6R*1325299004~AMT*B6*67.52~SVC*HC:T1019*67.
52*0****16~DTM*472*20130923~CAS*OA*42*67.52~REF*6R*1325299005~AMT*B6*67.52~SVC*HC:T1019*67.52*0***
*16~DTM*472*20130924~CAS*OA*42*67.52~REF*6R*1325299006~AMT*B6*67.52~SVC*HC:T1019*67.52*0****16~DTM
*472*20130925~CAS*OA*42*67.52~REF*6R*1325299007~AMT*B6*67.52~SVC*HC:T1019*67.52*0****16~DTM*472*20
130926~CAS*OA*42*67.52~REF*6R*1325299008~AMT*B6*67.52~SVC*HC:T1019*67.52*0****16~DTM*472*20130927~
CAS*OA*42*67.52~REF*6R*1325299009~AMT*B6*67.52~LX*27~'
Sunnyside.edi_parser(data)