require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  USER_ATTRIBUTES = {
    first_name: "Ana",
    last_name: "Viajera",
    phone: "+54 11 5555-1234",
    email: "ana@example.com",
    password: "password123",
    password_confirmation: "password123"
  }.freeze

  test "registration, logout and login" do
    assert_difference("User.count", 1) do
      post user_registration_path, params: { user: USER_ATTRIBUTES }
    end
    assert_redirected_to root_path
    assert_equal "Ana", User.last.first_name

    delete destroy_user_session_path
    assert_redirected_to root_path

    post user_session_path, params: { user: { email: USER_ATTRIBUTES[:email], password: USER_ATTRIBUTES[:password] } }
    assert_redirected_to root_path
  end

  test "rejects duplicate email, incorrect password and missing required names" do
    User.create!(USER_ATTRIBUTES)

    assert_no_difference("User.count") do
      post user_registration_path, params: { user: USER_ATTRIBUTES }
    end
    assert_response :unprocessable_entity

    delete destroy_user_session_path
    post user_session_path, params: { user: { email: USER_ATTRIBUTES[:email], password: "incorrecta" } }
    assert_response :unprocessable_entity

    invalid_attributes = USER_ATTRIBUTES.merge(first_name: "", last_name: "", email: "otra@example.com")
    assert_no_difference("User.count") do
      post user_registration_path, params: { user: invalid_attributes }
    end
    assert_response :unprocessable_entity
  end

  test "sends password recovery instructions" do
    User.create!(USER_ATTRIBUTES)

    assert_emails 1 do
      post user_password_path, params: { user: { email: USER_ATTRIBUTES[:email] } }
    end
    assert_redirected_to new_user_session_path
  end
end
