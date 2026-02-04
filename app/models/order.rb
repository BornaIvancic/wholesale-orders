class Order < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: "User"

  has_many :order_items, dependent: :destroy
  has_many :order_status_histories, dependent: :destroy
  has_one :offer, dependent: :destroy

  enum :status, {
    draft: 0,
    submitted: 1,
    approved: 2,
    rejected: 3,
    preparing: 4,
    shipped: 5,
    delivered: 6,
    cancelled: 7
  }

  validates :status, presence: true
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :products, through: :order_items

  def recalculate_total!
    update!(total_cents: order_items.sum(:line_total_cents))
  end

  VAT_RATE = 0.25

  def subtotal_cents
    total_cents
  end

  def vat_cents
    (subtotal_cents * VAT_RATE).round
  end

  def grand_total_cents
    subtotal_cents + vat_cents
  end
end