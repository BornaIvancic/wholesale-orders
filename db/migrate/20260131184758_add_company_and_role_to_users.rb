class AddCompanyAndRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :company, foreign_key: true, null: true
    add_column :users, :role, :integer, null: false, default: 0
  end
end