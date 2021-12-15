class MakeSchoolDeseIdUnique < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.execute('UPDATE schools SET dese_id = id')
    add_index :schools, :dese_id, unique: true
  end
end
