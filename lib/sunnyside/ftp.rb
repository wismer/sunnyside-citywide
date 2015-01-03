require "net/ftp"
require 'rubygems'

module Sunnyside
  def self.access_ftp
    Login.all.each do |login|
      access = SunnyFTP.new(site: login.site, username: login.username, password: login.password, provider: login.provider)
      access.log_on
      puts "Logged into #{access.name}..."
      access.check_for_new_files
    end
  end

  class SunnyFTP
    attr_reader :ftp, :username, :password, :name, :directory

    def initialize(login = {})
      @ftp      = Net::FTP.new(login[:site])
      @username = login[:username]
      @password = login[:password]
      @name     = login[:provider]
    end

    def log_on
      ftp.login(username, password)
    end

    def check_for_new_files
      ftp.chdir("../outgoing")
      incoming = IncomingFiles.new(ftp, name)
      incoming.download_files

      ftp.chdir("../incoming")
      outgoing = OutgoingFiles.new(ftp, name)
      outgoing.upload_files

      puts "Exiting #{name}..."
      ftp.close
    end


    def new_files
      files.map { |file| timestamp(file) + "-#{file}" }.select { |file| provider_folder.include?(timestamp(file)) }.size > 0
    end
  end

  class IncomingFiles < SunnyFTP
    attr_reader :file_records, :ftp_files, :ftp, :name

    def initialize(ftp, name)
      @file_records = Dir["#{DRIVE}/sunnyside-files/ftp/835/#{name}/*.pgp"].map { |file| File.basename(file).gsub(/^.{11}/, '') }
      @ftp_files    = ftp.nlst.select { |file| file.include?('835') }
      @ftp          = ftp
      @name         = name
    end

    def new_files
      ftp_files.select { |file| !file_records.include?(file) }
    end

    def download_files
      if new_files.size > 0
        new_files.each { |file| download_file(file) }
      else
        puts "No new files to download."
      end
    end

    def timestamp(file)
      ftp.mtime(file).strftime('%Y-%m-%d') + "-#{File.basename(file)}"
    end

    def download_file(file)
      puts "Downloading #{file}..."
      ftp.getbinaryfile(file, "#{DRIVE}/sunnyside-files/ftp/835/#{name}/#{timestamp(file)}")
    end
  end

  class OutgoingFiles < SunnyFTP
    attr_reader :ftp, :name

    def initialize(ftp, name)
      @name = name
      @ftp  = ftp
    end

    def new_files
      Dir["#{DRIVE}/sunnyside-files/ftp/837/#{name}/*.txt"]
    end

    def upload_files
      if new_files.size > 0
        new_files.each { |file| upload_file(file) }
      else
        puts "No new files to upload."
      end
    end

    def upload_file(file)
      ftp.putbinaryfile(file)
      puts "#{file} uploaded."
      puts "Deleting local file..."
      File.delete(file)
      puts "File deleted."
    end
  end
end

    # def up_files
    #   Dir["#{DRIVE}/sunnyside-files/ftp/837/#{name}/*.txt"]
    # end

    # def upload_files
    #   up_files.each { |file|
    #     if file.include?(name)
    #       puts "uploading #{file} for #{name}"
    #       ftp.putbinaryfile(file)
    #       puts "Upload complete."
    #       puts "deleting #{file} in local folder."
    #       FileUtils.mv(file, "#{DRIVE}/sunnyside-files/ftp/837/#{name}/#{File.basename(file)}")
    #     end
    #   }
    #   ftp.close
    # end