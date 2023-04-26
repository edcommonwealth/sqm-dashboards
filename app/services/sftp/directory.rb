require 'net/sftp'
require 'uri'
require 'csv'

module Sftp
  class Directory
    def self.open(path: '/data/survey_responses/clean', &block)
      sftptogo_url = ENV['MCIEA_SFTPTOGO_URL']
      uri = URI.parse(sftptogo_url)
      Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
        sftp.dir.foreach(path) do |entry|
          next unless entry.file?

          filename = entry.name
          puts filename

          sftp.file.open(filepath(path:, filename:), 'r', &block)
        end
      end
    end

    def self.filepath(path:, filename:)
      path += '/' unless path.end_with?('/')
      "#{path}#{filename}"
    end

    private_class_method :filepath
  end
end
