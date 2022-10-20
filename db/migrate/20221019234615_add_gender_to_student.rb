class AddGenderToStudent < ActiveRecord::Migration[7.0]
  def change
    add_reference :students, :gender, foreign_key: true
  end
end
