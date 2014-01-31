module Sunnyside
  PRIVATE_CLIENTS = ['TABICKMAN', 'JIBAJA', 'SUNNYSIDE COMMUNITY', 'BARROW', 'JENSEN']

  def self.private_clients
    Dir.mkdir("#{DRIVE}/sunnyside-files/pdf-reports/private") if !Dir.exist?("#{DRIVE}/sunnyside-files/pdf-reports/private")

    file      = Dir["#{DRIVE}/sunnyside-files/private/archive/*.PDF"].last 
    post_date = Date.parse(File.basename(file)[0..7])
    Invoice.where(post_date: post_date, provider_id: 16).all.each { |inv| puts "#{inv.client_id} #{Client[inv.client_id].client_name}"}
    puts "Type in the IDs next to the client's name, each separated by a space. "
    clients = gets.chomp.split.map { |client| Client[client].client_name }.push('SUNNYSIDE COMMUNITY')

    private_client = PrivateClient.new(file, post_date)
    clients.each { |client| private_client.create_doc(client) }
  end

  class PrivateClient
    attr_reader :file, :post_date

    def initialize(file, post_date)
      @file      = file
      @post_date = post_date
    end
    
    def selected_pages(name)
      PDF::Reader.new(file).pages.select { |page| page.text.include?(name) && page.text.include?('Client Copy') }.map { |page| page.number }
    end

    def create_doc(client)
      Prawn::Document.generate("#{DRIVE}/sunnyside-files/pdf-reports/private/#{client}-#{post_date}.PDF", :skip_page_creation => true) { |pdf| 
        selected_pages(client).each { |page| pdf.start_new_page(:template => file, :template_page => page) }
      }
      puts "file #{client}-#{post_date}.PDF created in #{DRIVE}/sunnyside-files/pdf-reports/private" 
    end
  end
end 