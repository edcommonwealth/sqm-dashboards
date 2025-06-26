class AddSocioEconomicStatusToParent < ActiveRecord::Migration[8.0]
  def change
    add_column :parents, :socio_economic_status, :integer, default: nil
  end
end
