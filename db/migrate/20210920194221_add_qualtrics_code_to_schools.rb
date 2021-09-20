class AddQualtricsCodeToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :qualtrics_code, :integer
  end
end
