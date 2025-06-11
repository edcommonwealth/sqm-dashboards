namespace :upload do
    desc 'upload cleaned ECP CSVs to the SFTP server'
    task surveys: :environment do
        new_files = Array.new
        input_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'clean')
        Dir.foreach(input_filepath) do |filename|
            next if filename.start_with?('.') # skip hidden files and ./.. directories
            # this can probably be replaced with Dir.join or similar
            input_filename = Rails.root.join('tmp', 'data', 'ecp_data', 'clean', filename).to_s
            sftp_url = ENV['SFTP_URL']
            uri = URI.parse(sftp_url)
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

    desc 'upload exported reports to the SFTP server'
    task exports: :environment do
        new_files = Array.new
        input_filepath = Rails.root.join('tmp', 'exports', '**', '*')
        Dir.glob(input_filepath) do |filename|
          next if filename.start_with?('.') # skip hidden files and ./.. directories
          next if File.directory?(filename) # skip directories

            # this can probably be replaced with Dir.join or similar
          input_filename = Rails.root.join('tmp', 'exports', filename).to_s
          sftp_url = ENV['SFTP_URL']
          uri = URI.parse(sftp_url)
          Net::SFTP.start(uri.host, uri.user, password: uri.password) do |sftp|
              puts "Uploading #{filename}..."

              upload_filename = filename.split('sqm-dashboards')[1][1..]
              upload_directory = upload_filename.rpartition('/').first
              tmp_dir = upload_directory + '/'
              parent_dir = "/"

              while tmp_dir.include?('/')
                first_dir = tmp_dir.split('/').first
                sftp.mkdir!("#{parent_dir}#{first_dir}/") unless sftp.dir.entries(parent_dir).map(&:name).include?(first_dir)

                parent_dir += first_dir + '/'
                tmp_dir = tmp_dir.split('/')[1..].join('/')
              end
              sftp.mkdir!("#{parent_dir}#{tmp_dir}/") unless sftp.dir.entries(parent_dir).map(&:name).include?(first_dir)
              sftp.upload!(input_filename, "/#{upload_filename}")
          end
          new_files.append(filename)
        end
        # print remote directory contents with new files marked
        path = '/tmp/exports/'
        Sftp::Directory.open(path:) do |file|
            # the open method already prints all the contents...
        end
    end
end
