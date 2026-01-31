class CreateOrderStatusHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_histories do |t|
      t.references :order, null: false, foreign_key: true

      t.integer :changed_by_id, null: false
      t.integer :from_status, null: false
      t.integer :to_status, null: false

      t.string :note

      t.timestamps
    end

    add_index :order_status_histories, :changed_by_id
    add_foreign_key :order_status_histories, :users, column: :changed_by_id
  end
end