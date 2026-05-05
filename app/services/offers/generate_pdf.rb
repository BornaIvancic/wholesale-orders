# frozen_string_literal: true

require 'prawn'
require 'prawn/table'
require 'stringio'

module Offers
  class GeneratePdf
    def initialize(offer:)
      @offer = offer
      @order = offer.order
      @company = @order.company
    end

    def call
      io = StringIO.new

      pdf = Prawn::Document.new

      # UTF-8 font (tvoje putanje)
      font_regular = File.expand_path('~/Library/Fonts/DejaVuSansMNerdFont-Regular.ttf')
      font_bold    = File.expand_path('~/Library/Fonts/DejaVuSansMNerdFont-Bold.ttf')

      pdf.font_families.update(
        'DejaVuSans' => { normal: font_regular, bold: font_bold }
      )
      pdf.font('DejaVuSans')

      header(pdf)
      partner(pdf)
      items(pdf)
      totals(pdf)

      io << pdf.render
      io.rewind

      attach_pdf(io)
    end

    private

    def header(pdf)
      pdf.text 'PONUDA', size: 20, style: :bold
      pdf.move_down 10
      pdf.text "Broj: #{@offer.number}"
      pdf.text "Datum: #{I18n.l(Time.zone.today)}"
      pdf.move_down 20
    end

    def partner(pdf)
      pdf.text 'Partner:', style: :bold
      pdf.text @company.name
      pdf.text "OIB: #{@company.oib}" if @company.oib.present?
      pdf.text @company.full_address if @company.full_address.present?
      pdf.move_down 10

      pdf.text 'Adresa dostave:', style: :bold
      pdf.text(@order.delivery_address.presence || @company.full_address.presence || '-')
      pdf.move_down 20
    end

    def items(pdf)
      rows = [['Proizvod', 'VPC', 'PDV', 'Kol.', 'MPC', 'Iznos']]

      @order.order_items.includes(:product).find_each do |item|
        rows << [
          item.product.name,
          money(item.unit_price_cents),
          money(item.unit_vat_cents),
          item.quantity,
          money(item.unit_mpc_cents),
          money(item.line_mpc_cents)
        ]
      end

      pdf.table(rows, header: true, width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = 'EEEEEE'
        cells.size = 9
        columns(1..5).align = :right
      end

      pdf.move_down 20
    end

    def totals(pdf)
      subtotal  = @order.subtotal_cents.to_i
      discount  = @order.discount_cents.to_i
      taxable   = [subtotal - discount, 0].max
      vat       = @order.vat_cents.to_i
      total     = @order.total_cents.to_i

      pdf.text "VPC ukupno: #{money(subtotal)}"
      pdf.text "Rabat: -#{money(discount)}"
      pdf.text "Osnovica: #{money(taxable)}"
      pdf.text "PDV (25%): #{money(vat)}"
      pdf.text "MPC ukupno: #{money(total)}", style: :bold

      pdf.move_down 12
      if @order.due_date.present?
        pdf.text "Rok plaćanja: #{I18n.l(@order.due_date)} (#{@company.payment_terms_days} dana)"
      elsif @company.payment_terms_days.present?
        pdf.text "Rok plaćanja: #{@company.payment_terms_days} dana"
      end
    end

    def attach_pdf(io)
      @offer.pdf.attach(
        io: io,
        filename: "offer-#{@offer.number}.pdf",
        content_type: 'application/pdf'
      )
    end

    def money(cents)
      format('€ %.2f', cents / 100.0)
    end
  end
end
