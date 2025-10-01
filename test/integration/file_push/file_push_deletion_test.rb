# frozen_string_literal: true

require "test_helper"

class FilePushDeletionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    Settings.enable_logins = true
    Settings.enable_file_pushes = true
    Rails.application.reload_routes!
    @luca = users(:luca)
    @luca.confirm
    sign_in @luca
  end

  teardown do
    sign_out :user
  end

  def test_deletion
    assert Settings.files.enable_deletable_pushes == true

    get new_push_path(tab: "files")
    assert_response :success

    post pushes_path, params: {
      push: {
        kind: "file",
        payload: "Message",
        files: [
          fixture_file_upload("monkey.png", "image/jpeg")
        ]
      }
    }
    assert_response :redirect

    # preview
    follow_redirect!
    assert_response :success
    assert_select "h2", "Your push has been created."

    # view the password
    get request.url.sub("/preview", "")
    assert_response :success

    # Delete the file_push
    delete expire_push_path(request.url.match(/\/p\/(.*)/)[1])
    assert_response :redirect

    # Get redirected to the password that is now expired
    follow_redirect!
    assert_response :success
  end

  def test_end_user_deletion_when_enabled
    assert Settings.files.enable_deletable_pushes == true

    get new_push_path(tab: "files")
    assert_response :success

    post pushes_path, params: {
      push: {
        kind: "file",
        payload: "Message",
        deletable_by_viewer: true,
        files: [
          fixture_file_upload("monkey.png", "image/jpeg")
        ]
      }
    }
    assert_response :redirect

    # preview
    follow_redirect!
    assert_response :success
    assert_select "h2", "Your push has been created."

    # view the password
    get request.url.sub("/preview", "")
    assert_response :success

    # Sign out user to test anonymous end user deletion
    sign_out :user

    # Delete the file_push
    delete expire_push_path(request.url.match(/\/p\/(.*)/)[1])
    assert_response :redirect

    # Get redirected to the password that is now expired
    follow_redirect!
    assert_response :success

    assert_select "p", "We apologize but this secret link has expired."

    # Retrieve the preliminary page.  It should show expired too.
    get preliminary_push_path(Push.last)
    assert_response :success
    assert response.body.include?("We apologize but this secret link has expired.")
  end
end
