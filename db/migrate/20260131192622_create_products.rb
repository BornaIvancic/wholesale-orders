class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.string  :sku, null: false
      t.integer :price_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :products, :sku, unique: true
  end
end