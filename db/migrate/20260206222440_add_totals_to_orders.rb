

class AddTotalsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :subtotal_cents, :integer, null: false, default: 0
    add_column :orders, :discount_cents, :integer, null: false, default: 0
    add_column :orders, :vat_cents, :integer, null: false, default: 0
    change_column_default :orders, :total_cents, 0
    change_column_null :orders, :total_cents, false
  end
end
