require "net/ftp"
require 'rubygems'

module Sunnyside
  def self.access_ftp
    puts "1.) GUILDNET"
    puts "2.) ELDERSERVE"
    puts "3.) CPHL"
    print "Select option: "
    case gets.chomp
    when '1'
      print 'Username for Guildnet? '
      username = gets.chomp
      print 'Password for Guildnet? '
      pass = gets.chomp
      access = SunnyFTP.new(username, pass, 'GUILDNET')
    when '2'
      print 'Username for ELDERSERVE? '
      username = gets.chomp
      print 'Password for ELDERSERVE? '
      pass = gets.chomp
      access = SunnyFTP.new(username, pass, 'ELDERSERVE')
    when '3'
      print 'Username for CPHL? '
      username = gets.chomp
      print 'Password for CPHL? '
      pass = gets.chomp
      access = SunnyFTP.new(username, pass, 'CPHL')
    else
      exit
    end
    access.log_on
    puts "Logged into #{access.name}..."
    access.download_files
    access.upload_files
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
      if ftp.nlst.size == 0
        puts "No files found. Exiting..."
        ftp.close
        return []
      else
        return ftp.nlst
      end
    end

    def up_files
      Dir["#{DRIVE}/sunnyside-files/ftp/837/#{name}/*.txt"]
    end

    def upload_files
      up_files.each { |file| 
        if file.include?(name)
          puts "uploading #{file} for #{name}"
          ftp.putbinaryfile(file)
          puts "Upload complete."
          puts "deleting #{file} in local folder."
          FileUtils.mv(file, "#{DRIVE}/sunnyside-files/ftp/837/#{name}/#{File.basename(file)}")
        end
      }      
      ftp.close
    end

    def provider_folder
      Dir["#{DRIVE}/sunnyside-files/ftp/835/#{name}"].map { |file| File.basename(file) }
    end

    def new_file?(file)
      provider_folder.include?(file)
    end

    def timestamp(file)
      ftp.mtime(file).strftime('%Y-%m-%d')
    end

    def download_files
      download_folder.each do |file|
        if !provider_folder.include?(file)
          if file.include?('835')
            puts "Downloading #{file}..."
            ftp.getbinaryfile(file, "#{DRIVE}/sunnyside-files/ftp/835/#{name}/#{timestamp(file)}-#{file}") 
            puts "#{file} placed, dated: #{timestamp(file)}."
          end
        end
      end
      ftp.close
    end
  end
end
