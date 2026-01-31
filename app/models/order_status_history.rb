class OrderStatusHistory < ApplicationRecord
  belongs_to :order
  belongs_to :changed_by, class_name: "User"

  validates :from_status, presence: true
  validates :to_status, presence: true
end