module Admin
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_product, only: %i[edit update destroy]

    def index
      @products = Product.order(:name)
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Proizvod je dodan."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Proizvod je ažuriran."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Proizvod je obrisan."
    end

    private

    def authorize_admin!
      authorize :admin, :access?
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :sku, :price_cents, :active)
    end
  end
end