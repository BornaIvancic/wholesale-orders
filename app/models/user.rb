class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true

  enum :role, { partner_user: 0, admin: 1 }
end