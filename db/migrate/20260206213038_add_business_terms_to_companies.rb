# frozen_string_literal: true

class AddBusinessTermsToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :discount_percent, :integer, null: false, default: 0
    add_column :companies, :payment_terms_days, :integer, null: false, default: 0
    add_column :companies, :offers_email, :string
  end
end
