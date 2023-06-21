namespace :upload do
    desc 'upload cleaned Lowell CSVs to the SFTP server'
    task lowell: :environment do
        new_files = Array.new
        input_filepath = Rails.root.join('tmp', 'data', 'rpp_data', 'clean')
        Dir.foreach(input_filepath) do |filename|
            next if filename.start_with?('.') # skip hidden files and ./.. directories
            # this can probably be replaced with Dir.join or similar
            input_filename = Rails.root.join('tmp', 'data', 'rpp_data', 'clean', filename).to_s
            sftptogo_url = ENV['SFTPTOGO_URL']
            uri = URI.parse(sftptogo_url)
            Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
                puts "Uploading #{filename}..."
                sftp.upload!(input_filename, "/data/survey_responses/clean/#{filename}")
            end
            new_files.append(filename)
        end
        # print remote directory contents with new files marked
        path = '/data/survey_responses/clean/'
        Sftp::Directory.open(path:) do |file|
            # the open method already prints all the contents...
        end
    end
    
    desc 'upload cleaned ECP CSVs to the SFTP server'
    task ecp: :environment do
        new_files = Array.new
        input_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'clean')
        Dir.foreach(input_filepath) do |filename|
            next if filename.start_with?('.') # skip hidden files and ./.. directories
            # this can probably be replaced with Dir.join or similar
            input_filename = Rails.root.join('tmp', 'data', 'ecp_data', 'clean', filename).to_s
            sftptogo_url = ENV['ECP_SFTPTOGO_URL']
            uri = URI.parse(sftptogo_url)
            Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
                puts "Uploading #{filename}..."
                sftp.upload!(input_filename, "/data/survey_responses/clean/#{filename}")
            end
            new_files.append(filename)
        end
        # print remote directory contents with new files marked
        path = '/data/survey_responses/clean/'
        Sftp::Directory.open(path:) do |file|
            # the open method already prints all the contents...
        end
    end
    
    desc 'upload cleaned MCIEA CSVs to the SFTP server'
    task mciea: :environment do
        new_files = Array.new
        input_filepath = Rails.root.join('tmp', 'data', 'mciea_data', 'clean')
        Dir.foreach(input_filepath) do |filename|
            next if filename.start_with?('.') # skip hidden files and ./.. directories
            # this can probably be replaced with Dir.join or similar
            input_filename = Rails.root.join('tmp', 'data', 'mciea_data', 'clean', filename).to_s
            sftptogo_url = ENV['MCIEA_SFTPTOGO_URL']
            uri = URI.parse(sftptogo_url)
            Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
                puts "Uploading #{filename}..."
                sftp.upload!(input_filename, "/data/survey_responses/clean/#{filename}")
            end
            new_files.append(filename)
        end
        # print remote directory contents with new files marked
        path = '/data/survey_responses/clean/'
        Sftp::Directory.open(path:) do |file|
            # the open method already prints all the contents...
        end
    end
end