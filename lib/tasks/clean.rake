namespace :clean do
  # These tasks must be run in their respective project so the correct schools are in the database
  desc 'clean ecp data'
  task ecp: :environment do
    input_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'raw')
    output_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'clean')
    log_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'removed')
    Cleaner.new(input_filepath:, output_filepath:, log_filepath:).clean
  end

  desc 'clean prepped data'
  task prepped: :environment do
    input_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'prepped')
    output_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'prepped', 'clean')
    log_filepath = Rails.root.join('tmp', 'data', 'ecp_data', 'prepped', 'removed')
    Cleaner.new(input_filepath:, output_filepath:, log_filepath:).clean
  end
  desc 'clean mciea data'
  task mciea: :environment do
    input_filepath = Rails.root.join('tmp', 'data', 'mciea_data', 'raw')
    output_filepath = Rails.root.join('tmp', 'data', 'mciea_data', 'clean')
    log_filepath = Rails.root.join('tmp', 'data', 'mciea_data', 'removed')
    Cleaner.new(input_filepath:, output_filepath:, log_filepath:).clean
  end

  desc 'clean rpp data'
  task rpp: :environment do
    input_filepath = Rails.root.join('tmp', 'data', 'rpp_data', 'raw')
    output_filepath = Rails.root.join('tmp', 'data', 'rpp_data', 'clean')
    log_filepath = Rails.root.join('tmp', 'data', 'rpp_data', 'removed')
    Cleaner.new(input_filepath:, output_filepath:, log_filepath:).clean
  end
end
