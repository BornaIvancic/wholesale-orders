module Admin
  class CompaniesController < ApplicationController
    before_action :authenticate_user!
    before_action -> { authorize :admin, :access? }

    def index
      @companies = Company.order(:name).page(params[:page]).per(20)
    end

    def new
      @company = Company.new(
        discount_percent: 0,
        payment_terms_days: 14
      )
    end

    def create
      @company = Company.new(company_params)

      if @company.save
        redirect_to admin_companies_path, notice: 'Partner je kreiran.'
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @company = Company.find(params[:id])
    end

    def update
      @company = Company.find(params[:id])
      if @company.update(company_params)
        redirect_to admin_companies_path, notice: 'Partner je ažuriran.'
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def company_params
      params.expect(company: %i[
        name
        discount_percent
        payment_terms_days
        offers_email
        street_address
        postal_code
        city
        oib
      ])
    end
  end
end