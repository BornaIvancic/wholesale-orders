class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :line_total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :quantity_cannot_exceed_stock

  before_validation :calculate_totals

  def unit_vat_cents
    (unit_price_cents.to_i * Orders::RecalculateTotals::VAT_RATE).round
  end

  def unit_mpc_cents
    unit_price_cents.to_i + unit_vat_cents
  end

  def line_vat_cents
    (line_total_cents.to_i * Orders::RecalculateTotals::VAT_RATE).round
  end

  def line_mpc_cents
    line_total_cents.to_i + line_vat_cents
  end

  private

  def calculate_totals
    return if product.nil?

    self.unit_price_cents ||= product.vpc_cents
    self.line_total_cents = unit_price_cents.to_i * quantity.to_i
  end

  def quantity_cannot_exceed_stock
    return if product.nil?
    return if quantity.blank?
    return unless quantity.to_i > product.stock_quantity.to_i

    errors.add(:quantity, "nije dostupna (na zalihi je #{product.stock_quantity})")
  end
end