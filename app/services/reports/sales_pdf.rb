

module Reports
  class SalesPdf
    def initialize(orders:, from:, to:, revenue_cents:, orders_count:)
      @orders = orders
      @from = from
      @to = to
      @revenue_cents = revenue_cents
      @orders_count = orders_count
    end

    def call
      pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
      Reports::PdfBase.new(pdf)

      pdf.text 'WineHub – Izvještaj prodaje', size: 18, style: :bold
      pdf.move_down 8
      pdf.text "Period: #{@from} – #{@to}"
      pdf.text "Broj narudžbi: #{@orders_count}"
      pdf.text "Prihod: #{eur(@revenue_cents)}"
      pdf.move_down 20

      rows = [['ID', 'Partner', 'Status', 'Datum', 'Total (€)']]

      @orders.includes(:company).order(created_at: :desc).each do |o|
        rows << [
          o.id,
          o.company&.name,
          o.status,
          o.created_at.strftime('%Y-%m-%d'),
          format('%.2f', o.total_cents.to_i / 100.0)
        ]
      end

      pdf.table(rows, header: true, width: pdf.bounds.width)
      pdf.render
    end

    private

    def eur(cents)
      format('%.2f €', cents.to_i / 100.0)
    end
  end
end
