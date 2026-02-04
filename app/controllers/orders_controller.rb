class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.company.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.company.orders.find(params[:id])
  end

  def new
    @order = Order.new
    @products = Product.where(active: true).order(:name)
  end

  def create
    @order = current_user.company.orders.build(
      created_by: current_user,
      status: :draft
    )

    params[:items]&.each do |product_id, quantity|
      next if quantity.to_i <= 0

      @order.order_items.build(
        product_id: product_id,
        quantity: quantity
      )
    end

    if @order.save
      @order.recalculate_total!
      redirect_to @order, notice: "Narudžba je kreirana."
    else
      @products = Product.where(active: true).order(:name)
      render :new, status: :unprocessable_entity
    end
  end
end