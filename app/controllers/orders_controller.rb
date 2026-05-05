# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_partner!

  def index
    @orders = current_user.company.orders

    if params[:query].present?
      query = params[:query].strip

      if query.match?(/\A\d+\z/)
        @orders = @orders.where(id: query.to_i)
      else
        @orders = @orders.none
      end
    end

    if params[:status].present?
      @orders = @orders.where(status: params[:status])
    end

    @orders =
      case params[:sort]
      when "oldest"
        @orders.order(created_at: :asc)
      when "total_asc"
        @orders.order(total_cents: :asc)
      when "total_desc"
        @orders.order(total_cents: :desc)
      else
        @orders.order(created_at: :desc)
      end

    @orders = @orders.page(params[:page]).per(20)
  end

  def show
    @order = current_user.company.orders.find(params[:id])
  end

  def new
    session[:draft_order_items] ||= {}

    @order = Order.new
    @products = Product.where(active: true)

    if params[:query].present?
      query = "%#{params[:query].strip}%"
      @products = @products.where("name ILIKE ? OR sku ILIKE ?", query, query)
    end

    if params[:category].present?
      @products = @products.where(category: params[:category])
    end

    case params[:availability]
    when "in_stock"
      @products = @products.where("stock_quantity > 0")
    when "out_of_stock"
      @products = @products.where(stock_quantity: 0)
    end

    @products =
      case params[:sort]
      when "price_asc"
        @products.order(price_cents: :asc)
      when "price_desc"
        @products.order(price_cents: :desc)
      when "name_desc"
        @products.order(name: :desc)
      else
        @products.order(name: :asc)
      end

    @products = @products.page(params[:page]).per(20)
    @categories = Product.where(active: true).where.not(category: [nil, ""]).distinct.order(:category).pluck(:category)
    @selected_items = session[:draft_order_items]
  end

  def create
    selected_items = session[:draft_order_items] || {}

    @order = current_user.company.orders.build(
      created_by: current_user,
      status: :draft,
      delivery_address: current_user.company.full_address
    )

    selected_items.each do |product_id, quantity|
      next if quantity.to_i <= 0

      @order.order_items.build(
        product_id: product_id,
        quantity: quantity
      )
    end

    if @order.order_items.empty?
      redirect_to new_order_path, alert: 'Odaberi barem jedan proizvod.'
      return
    end

    if @order.save
      Orders::RecalculateTotals.new(order: @order).call
      session[:draft_order_items] = {}
      redirect_to @order, notice: 'Narudžba je kreirana.'
    else
      @products = Product.where(active: true).order(:name).page(params[:page]).per(20)
      render :new, status: :unprocessable_content
    end
  end

  def add_item
    session[:draft_order_items] ||= {}

    @product = Product.find(params[:product_id])
    @quantity = params[:quantity].to_i

    if @quantity <= 0
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = 'Unesi količinu veću od 0.'
          render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
        end
        format.html { redirect_to new_order_path(filter_redirect_params), alert: 'Unesi količinu veću od 0.' }
      end
      return
    end

    if @quantity > @product.stock_quantity.to_i
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Nije moguće dodati više od dostupne zalihe (#{@product.stock_quantity})."
          render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
        end
        format.html { redirect_to new_order_path(filter_redirect_params), alert: "Nije moguće dodati više od dostupne zalihe (#{@product.stock_quantity})." }
      end
      return
    end

    session[:draft_order_items][@product.id.to_s] = @quantity
    @selected_items = session[:draft_order_items]

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to new_order_path(filter_redirect_params), notice: 'Proizvod je dodan u narudžbu.' }
    end
  end

  def change_status
    @order = current_user.company.orders.find(params[:id])

    result = Orders::ChangeStatus.new(
      order: @order,
      user: current_user,
      to_status: params[:to_status],
      note: params[:note]
    ).call

    if result.success?
      redirect_to @order, notice: 'Status je promijenjen.'
    else
      redirect_to @order, alert: result.error
    end
  end

  def submit
    @order = current_user.company.orders.find(params[:id])

    unless @order.submitable_by?(current_user)
      return redirect_to order_path(@order), alert: 'Ne možeš poslati ovu narudžbu.'
    end

    @order.update!(status: :submitted)
    @order.order_status_histories.create!(
      changed_by: current_user,
      from_status: Order.statuses[:draft],
      to_status: Order.statuses[:submitted],
      note: 'Partner poslao narudžbu'
    )

    redirect_to order_path(@order), notice: 'Narudžba je poslana.'
  end

  def update_delivery_address
    @order = current_user.company.orders.find(params[:id])

    unless @order.draft?
      redirect_to order_path(@order), alert: 'Adresu dostave možeš mijenjati samo dok je narudžba u draft statusu.'
      return
    end

    use_custom = params[:use_custom_delivery_address] == "1"
    custom_address = params[:delivery_address].to_s.strip

    final_address =
      if use_custom && custom_address.present?
        custom_address
      else
        current_user.company.full_address
      end

    @order.update!(delivery_address: final_address)

    redirect_to order_path(@order), notice: 'Adresa dostave je spremljena.'
  end

  private

  def ensure_partner!
    return if current_user.partner_user? && current_user.company.present?

    redirect_to root_path, alert: 'Partner korisnik mora imati dodijeljenu firmu.'
  end

  def filter_redirect_params
    params.permit(:query, :category, :availability, :sort, :page).to_h
  end
end