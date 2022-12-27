require 'net/sftp'
require 'uri'
require 'csv'

module Sftp
  class Downloader
    def initialize
      sftptogo_url = ENV['SFTPTOGO_URL']
      uri = URI.parse(sftptogo_url)
      Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
        # download a file or directory from the remote host
        # open and read from a pseudo-IO for a remote file
        # sftp.file.open('/mciea/data/canary.csv', 'r') do |f|
        #   CSV.parse(f.read) do |row|
        #     puts row
        #   end
        # end

        # list the entries in a directory
        sftp.dir.foreach('/mciea/data/') do |entry|
          puts entry.longname
        end
      end
    end
  end
end
