

module Admin
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action -> { authorize :admin, :access? }

    def index
      base = Order.joins(:company).includes(:company)

      orders =
        if params[:scope] == 'archive'
          base.where(status: :delivered).where.not(paid_at: nil)
        else
          base.where.not(
            id: base.where(status: :delivered).where.not(paid_at: nil).select(:id)
          )
        end

      if params[:query].present?
        query = params[:query].strip

        if query.match?(/\A\d+\z/)
          orders = orders.where(
            "orders.id = :id OR companies.name ILIKE :q",
            id: query.to_i,
            q: "%#{query}%"
          )
        else
          orders = orders.where("companies.name ILIKE ?", "%#{query}%")
        end
      end

      if params[:status].present?
        orders = orders.where(status: params[:status])
      end

      orders =
        case params[:sort]
        when "oldest"
          orders.order(created_at: :asc)
        when "company_asc"
          orders.order("companies.name ASC", created_at: :desc)
        when "company_desc"
          orders.order("companies.name DESC", created_at: :desc)
        else
          if params[:scope] == 'archive'
            orders.order(created_at: :desc)
          else
            orders.order(
              Arel.sql("CASE WHEN status = #{Order.statuses[:submitted]} THEN 0 ELSE 1 END"),
              created_at: :desc
            )
          end
        end

      @orders = orders.page(params[:page]).per(20)
    end

    def show
      @order = Order.find(params[:id])
    end

    def change_status
      @order = Order.find(params[:id])

      result = ::Orders::ChangeStatus.new(
        order: @order,
        user: current_user,
        to_status: params[:to_status],
        note: params[:note]
      ).call

      if result.success?
        redirect_to admin_order_path(@order), notice: 'Status je promijenjen.'
      else
        redirect_to admin_order_path(@order), alert: result.error
      end
    end

    def apply_discount
      @order = Order.find(params[:id])
      Orders::RecalculateTotals.new(order: @order).call
      redirect_to admin_order_path(@order), notice: 'Rabat i totals su preračunati.'
    end

    def generate_offer
      @order = Order.find(params[:id])

      offer = @order.offer || @order.create_offer!(
        number: "OFF-#{Time.zone.now.strftime('%Y%m%d')}-#{SecureRandom.hex(2).upcase}"
      )

      if @order.due_date.nil?
        @order.update!(
          due_date: Date.current + @order.company.payment_terms_days.days
        )
      end

      ::Offers::GeneratePdf.new(offer: offer).call

      redirect_to admin_order_path(@order), notice: 'Ponuda je generirana.'
    end

    def mark_paid
      @order = Order.find(params[:id])

      if @order.delivered? && @order.paid_at.nil?
        @order.update!(paid_at: Time.current)
        redirect_to admin_order_path(@order), notice: 'Narudžba označena kao plaćena.'
      else
        redirect_to admin_order_path(@order), alert: 'Narudžba se ne može označiti kao plaćena.'
      end
    end

    def send_offer
      @order = Order.find(params[:id])

      offer = @order.offer || @order.create_offer!(
        number: "OFF-#{Time.zone.now.strftime('%Y%m%d')}-#{SecureRandom.hex(2).upcase}"
      )

      ::Orders::RecalculateTotals.new(order: @order).call

      if @order.due_date.blank?
        days = @order.company.payment_terms_days.to_i
        @order.update!(due_date: Date.current + days.days) if days.positive?
      end

      sent_to = @order.company.offers_email
      if sent_to.blank?
        redirect_to admin_order_path(@order), alert: 'Company nema offers_email.'
        return
      end

      offer.update!(sent_to_email: sent_to)

      ::Offers::GeneratePdf.new(offer: offer).call

      OfferMailer.send_offer(offer).deliver_later

      offer.update!(sent_at: Time.zone.now)

      redirect_to admin_order_path(@order), notice: "Ponuda poslana na #{sent_to}."
    end
  end
end
