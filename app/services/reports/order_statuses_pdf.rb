# frozen_string_literal: true

module Reports
  class OrderStatusesPdf
    def initialize(rows:, from:, to:)
      @rows = rows
      @from = from
      @to = to
    end

    def call
      pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
      Reports::PdfBase.new(pdf)

      pdf.text 'WineHub – Statusi narudžbi', size: 18, style: :bold
      pdf.move_down 8
      pdf.text "Period: #{@from} – #{@to}"
      pdf.move_down 20

      data = [%w[Status Broj]]

      @rows.each do |status, count|
        data << [status, count]
      end

      pdf.table(data, header: true, width: pdf.bounds.width)
      pdf.render
    end
  end
end
