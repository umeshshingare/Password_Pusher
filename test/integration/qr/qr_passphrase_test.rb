# frozen_string_literal: true

require "test_helper"

class QrPassphraseTest < ActionDispatch::IntegrationTest
  setup do
    Settings.enable_logins = true
    Settings.enable_qr_pushes = true

    @luca = users(:luca)
    @luca.confirm
    sign_in @luca
  end

  teardown do
    sign_out :user
  end

  def test_password_passphrase
    get new_push_path(tab: "text")
    assert_response :success

    post pushes_path, params: {push: {kind: "qr", payload: "testqr", passphrase: "asdf"}}
    assert_response :redirect

    # Preview page
    follow_redirect!
    assert_response :success
    assert_select "h2", "Your push has been created."

    # Attempt to retrieve the password without the passphrase
    get request.url.sub("/preview", "")
    assert_response :redirect

    # We should get redirected to the passphrase page
    follow_redirect!
    assert_response :success

    # We should be on the passphrase page now

    # Validate passphrase form
    forms = css_select "form"
    assert_select "form input", 1
    input = css_select "input#passphrase.form-control"
    assert_equal input.first.attributes["placeholder"].value, "Enter the secret passphrase provided with this URL"

    # Provide the value passphrase
    post forms.first.attributes["action"].value, params: {passphrase: "asdf"}
    assert_response :redirect
    follow_redirect!
    assert_response :success

    # We should be on the password#show page now
    p_tags = assert_select "p"
    assert p_tags[0].text == "Please obtain and securely store this content in a secure manner, such as in a password manager."
    assert p_tags[1].text.include?("This secret link and all content will be deleted")
  end

  def test_password_bad_passphrase
    get new_push_path(tab: "text")
    assert_response :success

    post pushes_path, params: {push: {kind: "qr", payload: "testqr", passphrase: "asdf"}}
    assert_response :redirect

    # Preview page
    follow_redirect!
    assert_response :success
    assert_select "h2", "Your push has been created."

    # Attempt to retrieve the password without the passphrase
    get request.url.sub("/preview", "")
    assert_response :redirect

    # We should get redirected to the passphrase page
    follow_redirect!
    assert_response :success

    # We should be on the passphrase page now

    # Validate passphrase form
    forms = css_select "form"
    assert_select "form input", 1
    input = css_select "input#passphrase.form-control"
    failed_passphrase_log_count = AuditLog.where(kind: :failed_passphrase).count
    assert_equal input.first.attributes["placeholder"].value, "Enter the secret passphrase provided with this URL"

    # Provide a bad passphrase
    post forms.first.attributes["action"].value, params: {passphrase: "bad-passphrase"}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal failed_passphrase_log_count + 1, AuditLog.where(kind: :failed_passphrase).count

    # We should be back on the passphrase page now with an error message
    divs = css_select "div.alert-warning"
    assert divs.first.content.include?("That passphrase is incorrect")

    css_select "form"
    assert_select "form input", 1
    input = css_select "input#passphrase.form-control"
    assert_equal input.first.attributes["placeholder"].value, "Enter the secret passphrase provided with this URL"
  end
end
