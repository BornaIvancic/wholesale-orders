# frozen_string_literal: true

module Reports
  class TopPartnersPdf
    def initialize(rows:, from:, to:)
      @rows = rows
      @from = from
      @to = to
    end

    def call
      pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
      Reports::PdfBase.new(pdf)

      pdf.text 'WineHub – Top partneri', size: 18, style: :bold
      pdf.move_down 8
      pdf.text "Period: #{@from} – #{@to}"
      pdf.move_down 20

      data = [['ID', 'Partner', 'Narudžbe', 'Prihod (€)']]

      @rows.each do |r|
        data << [
          r.id,
          r.name,
          r.orders_count.to_i,
          format('%.2f', r.revenue_cents.to_i / 100.0)
        ]
      end

      pdf.table(data, header: true, width: pdf.bounds.width)
      pdf.render
    end
  end
end
