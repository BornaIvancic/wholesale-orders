

class Order < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'

  has_many :order_items, dependent: :destroy
  has_many :order_status_histories, dependent: :destroy
  has_one :offer, dependent: :destroy

  has_many :products, through: :order_items

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

  # totals (sprema se u DB preko Orders::RecalculateTotals)
  validates :subtotal_cents, :discount_cents, :vat_cents, :total_cents,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  def grand_total_cents
    total_cents.to_i
  end

  def submitable_by?(user)
    user.partner_user? && draft? && user.company_id == company_id
  end
  scope :overdue, lambda {
    where(due_date: ...Date.current)
      .where(paid_at: nil)
  }

  def overdue?
    due_date.present? && due_date < Date.current && paid_at.nil?
  end

  def paid?
    paid_at.present?
  end

  def finished?
    delivered? && paid?
  end
  scope :archived, -> { where(status: :delivered).where.not(paid_at: nil) }
  def due_date
    base_date = approved_at || created_at
    return nil unless base_date && company&.payment_terms_days.present?

    base_date.to_date + company.payment_terms_days.days
  end
  scope :archived, -> { where(status: :delivered).where.not(paid_at: nil) }

  scope :active, lambda {
    where.not(id: archived.select(:id))
  }
end
