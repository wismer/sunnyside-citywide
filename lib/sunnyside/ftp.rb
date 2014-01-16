require "net/ftp"
require 'rubygems'

module Sunnyside
  def self.access_ftp(process)
    puts "1.) GUILDNET"
    puts "2.) ELDERSERVE"
    puts "3.) CPHL"
    print "Select option: "
    case gets.chomp
    when '1'
      puts 'Password for Guildnet?'
      pass = gets.chomp
      access = SunnyFTP.new('mcogssideftp', pass, 'GUILDNET')
    when '2'
      puts 'Password for ELDERSERVE?'
      pass = gets.chomp
      access = SunnyFTP.new('mcoesunc', pass, 'ELDERSERVE')
    when '3'
      puts 'Password for CPHL?'
      pass = gets.chomp
      access = SunnyFTP.new('mcocetsunch', pass, 'CPHL')
    else
      exit
    end
    access.log_on
    puts "Logged into #{access.name}..."
    if process == :download
      access.download_files
    elsif process == :upload
      access.upload_files
    end
  end

  class SunnyFTP
    attr_reader :ftp, :username, :password, :name, :directory

    def initialize(username, password, name)
      @ftp      = Net::FTP.new('depot.per-se.com')
      @username = username
      @password = password
      @name     = name      
    end

    def log_on
      ftp.login(username, password)
    end

    def empty?(folder)
      ftp.list(folder) == ["total 0"]
    end

    def outgoing_contents
      ftp.nlst('../outgoing') if empty?('../outgoing') 
    end

    def download_folder
      ftp.chdir('../outgoing')
      if !empty?('.')
        puts "No files found. Exiting..."
        ftp.close
        return []
      else
        return ftp.nlst
      end
    end

    def up_files
      Dir["#{DRIVE}/ftp/outgoing/*.txt"]
    end

    def upload_files
      up_files.each { |file| 
        if file.include?(name)
          puts "uploading #{file} for #{name}"
          ftp.putbinaryfile(file)
          puts "Upload complete."
          puts "deleting #{file} in local folder."
          FileUtils.mv(file, "#{DRIVE}/ftp/837/#{name}/#{File.basename(file)}")
        end
      }      
      ftp.close
    end

    def provider_folder
      Dir["ftp/835/#{name}"].map { |file| File.basename(file) }
    end

    def new_file?(file)
      provider_folder.include?(file)
    end

    def download_files
      download_folder.each do |file|
        if !provider_folder.include?(file)
          puts "Downloading #{file}..."
          ftp.getbinaryfile(file, "#{DRIVE}/ftp/835/#{name}/#{file}") if File.basename(file).include?('835')
          puts "#{file} placed."
        end
      end
      ftp.close
    end
  end
end
