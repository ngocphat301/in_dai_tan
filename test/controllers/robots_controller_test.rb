# frozen_string_literal: true

require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  test "show lists sitemap and disallows private paths" do
    get "/robots.txt"
    assert_response :success
    assert_match %r{Sitemap: http://www\.example\.com/sitemap\.xml}, response.body
    assert_includes response.body, "Disallow: /admin"
    assert_includes response.body, "Disallow: /users"
    assert_includes response.body, "Disallow: /search"
  end
end
