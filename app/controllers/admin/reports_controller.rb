

require 'csv'

module Admin
  class ReportsController < ApplicationController
    before_action :authenticate_user!
    before_action -> { authorize :admin, :access? }

    def index; end

    def sales
      range  = date_range
      orders = Order.where(created_at: range).where.not(status: :cancelled)

      @from = range.first.to_date
      @to = range.last.to_date
      @orders_count = orders.count
      @revenue_cents = orders.sum(:total_cents)

      respond_to do |format|
        format.html
        format.csv { send_data sales_csv(orders), filename: "sales-#{@from}-#{@to}.csv" }
        format.pdf do
          pdf = ::Reports::SalesPdf.new(
            orders: orders,
            from: @from,
            to: @to,
            revenue_cents: @revenue_cents,
            orders_count: @orders_count
          ).call

          send_data pdf,
                    filename: "sales-#{@from}-#{@to}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end

    def top_products
      range = date_range
      items = OrderItem.joins(:order, :product)
                       .where(orders: { created_at: range })
                       .where.not(orders: { status: :cancelled })
                       .group('products.id', 'products.name', 'products.sku')
                       .select('products.id, products.name, products.sku, SUM(order_items.quantity) AS qty, SUM(order_items.line_total_cents) AS revenue_cents')
                       .order(Arel.sql('revenue_cents DESC'))

      @from = range.first.to_date
      @to = range.last.to_date
      @rows = items

      respond_to do |format|
        format.html
        format.csv { send_data top_products_csv(items), filename: "top-products-#{@from}-#{@to}.csv" }
        format.pdf do
          pdf = ::Reports::TopProductsPdf.new(rows: @rows, from: @from, to: @to).call

          send_data pdf,
                    filename: "top-products-#{@from}-#{@to}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end

    def top_partners
      range = date_range
      rows = Order.joins(:company)
                  .where(created_at: range)
                  .where.not(status: :cancelled)
                  .group('companies.id', 'companies.name')
                  .select('companies.id, companies.name, COUNT(orders.id) AS orders_count, SUM(orders.total_cents) AS revenue_cents')
                  .order(Arel.sql('revenue_cents DESC'))

      @from = range.first.to_date
      @to = range.last.to_date
      @rows = rows

      respond_to do |format|
        format.html
        format.csv { send_data top_partners_csv(rows), filename: "top-partners-#{@from}-#{@to}.csv" }
        format.pdf do
          pdf = ::Reports::TopPartnersPdf.new(rows: @rows, from: @from, to: @to).call

          send_data pdf,
                    filename: "top-partners-#{@from}-#{@to}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end

    def order_statuses
      range = date_range
      rows = Order.where(created_at: range)
                  .group(:status)
                  .count

      @from = range.first.to_date
      @to = range.last.to_date
      @rows = rows # { "draft"=>3, "approved"=>5 ... }

      respond_to do |format|
        format.html
        format.csv { send_data order_statuses_csv(rows), filename: "order-statuses-#{@from}-#{@to}.csv" }
        format.pdf do
          pdf = ::Reports::OrderStatusesPdf.new(rows: @rows, from: @from, to: @to).call

          send_data pdf,
                    filename: "order-statuses-#{@from}-#{@to}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end

    private

    def date_range
      from = params[:from].presence&.to_date || 30.days.ago.to_date
      to   = params[:to].presence&.to_date || Date.current
      from.beginning_of_day..to.end_of_day
    end

    def sales_csv(orders)
      ::CSV.generate(headers: true) do |csv|
        csv << %w[order_id company status created_at total_eur]
        orders.includes(:company).find_each do |o|
          csv << [o.id, o.company&.name, o.status, o.created_at.to_s, (o.total_cents.to_i / 100.0)]
        end
      end
    end

    def top_products_csv(rows)
      ::CSV.generate(headers: true) do |csv|
        csv << %w[product_id name sku qty revenue_eur]
        rows.each { |r| csv << [r.id, r.name, r.sku, r.qty.to_i, (r.revenue_cents.to_i / 100.0)] }
      end
    end

    def top_partners_csv(rows)
      ::CSV.generate(headers: true) do |csv|
        csv << %w[company_id company orders_count revenue_eur]
        rows.each { |r| csv << [r.id, r.name, r.orders_count.to_i, (r.revenue_cents.to_i / 100.0)] }
      end
    end

    def order_statuses_csv(rows)
      ::CSV.generate(headers: true) do |csv|
        csv << %w[status count]
        rows.each { |status, count| csv << [status, count] }
      end
    end
  end
end
