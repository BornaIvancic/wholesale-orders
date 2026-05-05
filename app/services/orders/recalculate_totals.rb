

module Orders
  class RecalculateTotals
    VAT_RATE = 0.25

    def initialize(order:)
      @order = order
    end

    def call
      subtotal = @order.order_items.sum(:line_total_cents)

      discount = if @order.company&.discount_percent.to_i.positive?
                   ((subtotal * @order.company.discount_percent.to_i) / 100.0).round
                 else
                   0
                 end

      taxable = [subtotal - discount, 0].max
      vat = (taxable * VAT_RATE).round
      total = taxable + vat

      @order.update!(
        subtotal_cents: subtotal,
        discount_cents: discount,
        vat_cents: vat,
        total_cents: total
      )

      @order
    end
  end
end
