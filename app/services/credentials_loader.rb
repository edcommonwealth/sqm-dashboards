require "csv"

class CredentialsLoader
  def self.load_credentials(file:)
    credentials = []
    CSV.parse(file, headers: true) do |row|
      values = CredentialRowValues.new(row:)
      next unless values.district.present?

      credentials << values.district
    end
    District.import(credentials, batch_size: 100, on_duplicate_key_update: [:username, :password, :login_required])
  end
end

class CredentialRowValues
  attr_reader :row

  def initialize(row:)
    @row = row
  end

  def district
    @district ||= begin
      name = row["Districts"]&.strip
      district = District.find_or_initialize_by(name:)
      district.username = username
      district.password = password
      district.login_required = login_required?
      district
    end
  end

  def username
    row["Username"]&.strip
  end

  def password
    row["PW"]&.strip
  end

  def login_required?
    row["Login Required"]&.strip == "Y"
  end
end
