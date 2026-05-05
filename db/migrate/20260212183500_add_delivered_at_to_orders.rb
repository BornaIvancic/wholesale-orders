# frozen_string_literal: true

class AddDeliveredAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :delivered_at, :datetime
  end
end
