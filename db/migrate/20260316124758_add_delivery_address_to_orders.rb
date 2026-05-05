class AddDeliveryAddressToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :delivery_address, :text
  end
end
