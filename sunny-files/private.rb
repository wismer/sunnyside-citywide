require 'prawn'

module Sunnyside
  PRIVATE_CLIENTS = ['TABICKMAN', 'JIBAJA', 'SUNNYSIDE COMMUNITY', 'BARROW', 'JENSEN']
  def self.private_clients
    Dir['private/*.PDF'].each do |file|
      priv_client = PrivateClient.new(file)
      priv_client.create_pdfs
    end
  end

  class PrivateClient
    attr_reader :file

    def initialize(file)
      @file            = file
      @selected        = []
    end
#create_doc(page, 'TABICKMAN')
    def tabickman
      selected_pages('TABICKMAN')
    end

    def jibaja
      selected_pages('JIBAJA')
    end

    def community
      selected_pages('SUNNYSIDE COMMUNITY')
    end

    def jensen
      selected_pages('JENSEN')
    end

    def barrow
      selected_pages('BARROW')
    end

    def selected_pages(name)
      PDF::Reader.new(file).pages.select { |page| page.text.include?(name) && page.text.include?('Client Copy') }.map { |page| page.number }
    end

    def date_parse
      Date.parse(file[8..15])
    end

    def create_doc(client)
      Prawn::Document.generate("./private/archive/#{client}-#{date_parse}.PDF", :skip_page_creation => true) { |pdf| 
        selected_pages(client).each { |page| pdf.start_new_page(:template => file, :template_page => page) }
      }
      puts 'files created in ../private/archive/' 
    end

    def create_pdfs
      PRIVATE_CLIENTS.each { |client| create_doc(client) }
    end
  end
end