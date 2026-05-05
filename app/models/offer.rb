

class Offer < ApplicationRecord
  belongs_to :order
  has_one_attached :pdf
  validates :number, presence: true, length: { maximum: 50 }
end
