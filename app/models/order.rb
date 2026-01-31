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
end