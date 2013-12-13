require 'sequel'
module Sunnyside
  DB = Sequel.connect('sqlite://./project.db')
  def self.ledger_file
    root_dir = Dir["../*.pdf"].each {|file| Filter.new(file).process_file if !Filelib.map(:filename).include?(file)} || []
    puts "No files to process." if root_dir.empty? 
  end
  class Filter
    attr_accessor :post_date, :file # Filter filters out pages that are not meant to be scanned
    attr_reader   :post_date, :file

    def initialize(file)
      @post_date = Date.parse(file[0..7])
      @file      = file
    end
    
    def process_file
      PDF::Reader.new("./summary/"+file).pages.select{|page| !page.raw_content.include?('VISITING NURSE SERVICE')}.each do |t| 
        ProcessPage.new(t.raw_content, post_date)
      end
      Filelib.insert(filename: @file, purpose: 'Ledger import', file_type: '.pdf', created_at: Time.now)
    end

    class ProcessPage
      def initialize()
        
      end
  end
  class Auth < Sequel::Model; end
  class Charge < Sequel::Model; end
  class Invoice < Sequel::Model; end
  class Filelib < Sequel::Model; end
  class Payment < Sequel::Model; end
  class Claim < Sequel::Model; end
  class Client < Sequel::Model; end
  class Service < Sequel::Model; end
  class Provider < Sequel::Model; end
end