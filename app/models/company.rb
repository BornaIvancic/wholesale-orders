class Company < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :orders, dependent: :restrict_with_exception

  validates :name, presence: true, length: { maximum: 255 }

  validates :discount_percent,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  validates :payment_terms_days,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 365 }

  validates :offers_email,
            allow_blank: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :oib,
            allow_blank: true,
            format: { with: /\A\d{11}\z/, message: "mora imati točno 11 znamenki" }

  def full_address
    [street_address, [postal_code, city].reject(&:blank?).join(" ")].reject(&:blank?).join(", ")
  end
end