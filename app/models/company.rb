class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true, length: { maximum: 120 }
end