require "net/ftp"
require 'openpgp'
require 'rubygems'

module Sunnyside
  PROVIDERS = [ 
                { :username => '****', :password => '****', :name => 'GUILDNET'}, 
                { :username => '****', :password => '****', :name => 'ELDERSERVE'}, 
                { :username => '****', :password => '****', :name => 'CPHL'}
              ]
  def self.access_ftp(process)
    PROVIDERS.each { |provider| 
      access = SunnyFTP.new(provider)
      access.log_on
      puts "Logged into #{provider[:name]}..."
      if process == :download
        access.download_files
      elsif process == :upload
        access.upload_files
      end
    }
  end

  class SunnyFTP
    attr_reader :ftp, :username, :password, :name, :directory

    def initialize(provider = {})
      @ftp      = Net::FTP.new('depot.per-se.com')
      @username = provider[:username]
      @password = provider[:password]
      @name     = provider[:name]      
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
      Dir["edi/outgoing/*.txt"]
    end

    def upload_files
      up_files.each { |file| 
        if file.include?(name)
          puts "uploading #{file} for #{name}"
          ftp.putbinaryfile(file)
          puts "Upload complete."
          puts "deleting #{file} in local folder."
          FileUtils.mv(file, "edi/outgoing/uploaded/#{File.basename(file)}")
        end
      }      
      ftp.close
    end

    def provider_folder
      Dir["edi/incoming/#{name}"].map { |file| File.basename(file) }
    end

    def new_file?(file)
      provider_folder.include?(file)
    end

    def download_files
      download_folder.each do |file|
        if !provider_folder.include?(file)
          puts "Downloading #{file}..."
          case file
          when file.include?('TA1') then ftp.getbinaryfile(file, "edi/incoming/#{name}/TA1/#{file}")
          when file.include?('997') then ftp.getbinaryfile(file, "edi/incoming/#{name}/997/#{file}")
          else
            ftp.getbinaryfile(file, "edi/incoming/#{name}/#{file}")
          end
          puts "#{file} placed."
        end
      end
      ftp.close
    end
  end
end
