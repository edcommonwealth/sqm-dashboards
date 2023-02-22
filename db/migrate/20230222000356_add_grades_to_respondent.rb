class AddGradesToRespondent < ActiveRecord::Migration[7.0]
  def change
    add_column :respondents, :pk, :integer
    add_column :respondents, :k, :integer
    add_column :respondents, :one, :integer
    add_column :respondents, :two, :integer
    add_column :respondents, :three, :integer
    add_column :respondents, :four, :integer
    add_column :respondents, :five, :integer
    add_column :respondents, :six, :integer
    add_column :respondents, :seven, :integer
    add_column :respondents, :eight, :integer
    add_column :respondents, :nine, :integer
    add_column :respondents, :ten, :integer
    add_column :respondents, :eleven, :integer
    add_column :respondents, :twelve, :integer
  end
end
