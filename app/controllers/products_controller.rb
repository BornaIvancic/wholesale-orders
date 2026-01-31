class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.where(active: true).order(:name)
  end

  def show
    @product = Product.where(active: true).find(params[:id])
  end
end