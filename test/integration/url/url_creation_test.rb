# frozen_string_literal: true

require "test_helper"

class UrlCreationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    Settings.enable_logins = true
    Settings.enable_url_pushes = true
    Rails.application.reload_routes!

    @luca = users(:luca)
    @luca.confirm
    sign_in @luca
  end

  teardown do
    sign_out @luca
  end

  def test_textarea_has_safeties
    get new_push_path(tab: "url")
    assert_response :success

    # Validate some elements
    input = css_select "input#push_payload.form-control"

    assert input.attribute("spellcheck")
    assert input.attribute("spellcheck").value == "false"

    assert input.attribute("autocomplete")
    assert input.attribute("autocomplete").value == "off"

    assert input.attribute("autofocus")
    assert input.attribute("autofocus").value == "autofocus"

    assert input.attribute("required")
    assert input.attribute("required").value == "required"
  end

  def test_url_creation
    get new_push_path(tab: "url")
    assert_response :success

    post pushes_path, params: {push: {kind: "url", payload: "https://the0x00.dev"}}
    assert_response :redirect

    # Preview page
    follow_redirect!
    assert_response :success
    assert_select "h2", "Your push has been created."

    # url page
    get request.url.sub("/preview", "")
    assert_response :redirect
    assert response.redirect_url == "https://the0x00.dev"
  end

  def test_url_creation_with_error
    get new_push_path(tab: "url")
    assert_response :success

    post pushes_path, params: {push: {kind: "url", payload: "the0x00.dev"}}
    assert_response :unprocessable_entity
    assert_select "div", "1 error prohibited this push from being saved: Payload must be a valid HTTP or HTTPS URL."
  end
end
