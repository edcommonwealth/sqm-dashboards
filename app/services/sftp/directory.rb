require 'net/sftp'
require 'uri'

module Sftp
  class Directory
    def self.open(path: '/data/survey_responses/clean', &block)
      sftp_url = ENV['SFTP_URL']
      uri = URI.parse(sftp_url)
      local_dir = Rails.root.join('tmp', 'uploads')
      FileUtils.mkdir_p(local_dir)

      downloaded_files = []

      Net::SFTP.start(uri.host, uri.user, password: uri.password, keepalive: true, keepalive_interval: 5) do |sftp|
        sftp.dir.foreach(path) do |entry|
          next unless entry.file?

          filename = entry.name
          puts filename

          local_path = local_dir.join(filename)
          sftp.download!(filepath(path:, filename:), local_path.to_s)
          downloaded_files << local_path
        end
      end

      begin
        downloaded_files.each do |file_path|
          ::File.open(file_path, 'r') do |file|
            block.call(file)
          end
        end
      ensure
        downloaded_files.each do |file_path|
          ::File.delete(file_path) if ::File.exist?(file_path)
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
