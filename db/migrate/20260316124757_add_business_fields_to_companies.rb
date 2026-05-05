class AddBusinessFieldsToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :street_address, :string
    add_column :companies, :postal_code, :string
    add_column :companies, :city, :string
    add_column :companies, :oib, :string
  end
end
