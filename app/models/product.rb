class Product < ApplicationRecord
  VAT_RATE = 0.25

  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 120 }
  validates :sku, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def in_stock?
    stock_quantity.to_i.positive?
  end

  def mpc_cents
    price_cents.to_i
  end

  def vpc_cents
    (mpc_cents / (1 + VAT_RATE)).round
  end

  def pdv_cents
    mpc_cents - vpc_cents
  end
end