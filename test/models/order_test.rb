# frozen_string_literal: true

require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "order is overdue when due date is past and not paid" do
    company = Company.create!(
      name: "Test firma",
      payment_terms_days: 1,
      discount_percent: 0
    )

    user = User.create!(
      email: "admin_order_test@test.com",
      password: "password123",
      role: :admin
    )

    order = Order.new(
      company: company,
      created_by: user,
      status: :approved,
      approved_at: 5.days.ago,
      paid_at: nil
    )

    assert order.overdue?
  end

  test "order is not overdue when paid" do
    order = Order.new(
      due_date: Date.yesterday,
      paid_at: Time.current
    )

    assert_not order.overdue?
  end

  test "order is finished when delivered and paid" do
    order = Order.new(
      status: :delivered,
      paid_at: Time.current
    )

    assert order.finished?
  end
end