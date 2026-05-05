

module Admin
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_product, only: %i[edit update destroy]

    def index
      @products = Product.all

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
      when "active"
        @products = @products.where(active: true)
      when "inactive"
        @products = @products.where(active: false)
      end

      @products =
        case params[:sort]
        when "price_asc"
          @products.order(price_cents: :asc)
        when "price_desc"
          @products.order(price_cents: :desc)
        when "stock_asc"
          @products.order(stock_quantity: :asc)
        when "stock_desc"
          @products.order(stock_quantity: :desc)
        when "name_desc"
          @products.order(name: :desc)
        else
          @products.order(name: :asc)
        end

      @products = @products.page(params[:page]).per(20)

      @categories = Product.where.not(category: [nil, ""])
                           .distinct
                           .pluck(:category)
                           .sort
    end

    def new
      @product = Product.new
    end

    def edit; end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: 'Proizvod je dodan.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: 'Proizvod je ažuriran.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: 'Proizvod je obrisan.'
    end

    private

    def authorize_admin!
      authorize :admin, :access?
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.expect(product: %i[name sku price_cents active stock_quantity])
    end
  end
end
