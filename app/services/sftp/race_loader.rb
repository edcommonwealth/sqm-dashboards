require 'net/sftp'
require 'uri'
require 'csv'

module Sftp
  class RaceLoader
    def self.load_data(path: '/data/survey_responses/')
      SurveyItemResponse.update_all(student_id: nil)
      StudentRace.delete_all
      Student.delete_all

      sftptogo_url = ENV['SFTPTOGO_URL']
      uri = URI.parse(sftptogo_url)
      Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
        sftp.dir.foreach(path) do |entry|
          filename = entry.name
          puts filename

          sftp.file.open(filepath(path:, filename:), 'r') do |f|
            StudentLoader.from_file(file: f, rules: [Rule::SkipNonLowellSchools])
          end
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
