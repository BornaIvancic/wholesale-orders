# frozen_string_literal: true

class AddDueDateAndPaidAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :due_date, :date
    add_column :orders, :paid_at, :datetime
  end
end
