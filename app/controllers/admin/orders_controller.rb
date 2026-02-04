module Admin
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action -> { authorize :admin, :access? }

    def index
      @orders = Order.includes(:company).order(created_at: :desc)
    end

    def show
      @order = Order.find(params[:id])
    end
  end
end