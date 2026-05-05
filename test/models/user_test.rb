# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "partner user must have company" do
    user = User.new(
      email: "partner@test.com",
      password: "password123",
      role: :partner_user
    )

    assert_not user.valid?
    assert_includes user.errors[:company], "can't be blank"
  end

  test "admin user can be valid without company" do
    user = User.new(
      email: "admin_unique@test.com",
      password: "password123",
      role: :admin
    )

    assert user.valid?, user.errors.full_messages.to_sentence
  end
end