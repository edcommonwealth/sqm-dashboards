class AddQualtricsCodeToDistricts < ActiveRecord::Migration[5.0]
  def change
    add_column :districts, :qualtrics_code, :integer
  end
end
