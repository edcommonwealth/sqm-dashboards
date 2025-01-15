class AddTotalEspToRespondents < ActiveRecord::Migration[8.0]
  def change
    add_column :respondents, :total_esp, :integer
  end
end
