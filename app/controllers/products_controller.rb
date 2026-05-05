# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.where(active: true)

    # SEARCH
    if params[:query].present?
      query = "%#{params[:query].strip}%"
      @products = @products.where("name ILIKE ? OR sku ILIKE ?", query, query)
    end

    # CATEGORY FILTER
    if params[:category].present?
      @products = @products.where(category: params[:category])
    end

    # AVAILABILITY FILTER
    case params[:availability]
    when "in_stock"
      @products = @products.where("stock_quantity > 0")
    when "out_of_stock"
      @products = @products.where(stock_quantity: 0)
    end

    # SORTING
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

    # PAGINATION
    @products = @products.page(params[:page]).per(24)

    # CATEGORY LIST FOR DROPDOWN
    @categories = Product.where.not(category: [nil, ""])
                         .distinct
                         .pluck(:category)
                         .sort
  end

  def show
    @product = Product.where(active: true).find(params[:id])
  end
end