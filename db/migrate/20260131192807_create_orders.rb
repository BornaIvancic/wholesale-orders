class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :company, null: false, foreign_key: true

      t.integer :created_by_id, null: false
      t.integer :status, null: false, default: 0
      t.integer :total_cents, null: false, default: 0

      t.text :notes

      t.timestamps
    end

    add_index :orders, :created_by_id
    add_foreign_key :orders, :users, column: :created_by_id
  end
end