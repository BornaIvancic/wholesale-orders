class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.integer :quantity, null: false, default: 1
      t.integer :unit_price_cents, null: false
      t.integer :line_total_cents, null: false

      t.timestamps
    end

    add_index :order_items, [:order_id, :product_id], unique: true
  end
end