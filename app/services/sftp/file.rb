require 'net/sftp'
require 'uri'

module Sftp
  class File
    def self.open(filepath:, &block)
      sftp_url = ENV['SFTP_URL']
      uri = URI.parse(sftp_url)
      Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
        sftp.file.open(filepath, 'r', &block)
      end
    rescue Net::SFTP::StatusException => e
      puts "Error opening file: #{e.message}"
      nil
    end
  end
end
