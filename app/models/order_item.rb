class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :line_total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :calculate_totals

  private
  def calculate_totals
    return if product.nil?

    self.unit_price_cents ||= product.price_cents
    self.line_total_cents = unit_price_cents.to_i * quantity.to_i
  end
end