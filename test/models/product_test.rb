require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "product is valid with valid attributes" do
    product = Product.new(
      name: "Test proizvod",
      sku: "TEST123",
      price_cents: 1000,
      stock_quantity: 10
    )

    assert product.valid?
  end

  test "product is invalid without name" do
    product = Product.new(
      sku: "TEST123",
      price_cents: 1000
    )

    assert_not product.valid?
  end

  test "product stock cannot be negative" do
    product = Product.new(
      name: "Test",
      sku: "TEST123",
      price_cents: 1000,
      stock_quantity: -5
    )

    assert_not product.valid?
  end
end