# frozen_string_literal: true

class AddStockQuantityToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :stock_quantity, :integer, null: false, default: 0
    add_index :products, :stock_quantity
  end
end
