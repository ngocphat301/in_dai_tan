# frozen_string_literal: true

require "test_helper"

class RobotsTxtTest < ActiveSupport::TestCase
  test "public/robots.txt disallows private paths and lists sitemap" do
    body = Rails.public_path.join("robots.txt").read

    assert_includes body, "Disallow: /admin"
    assert_includes body, "Disallow: /users"
    assert_includes body, "Disallow: /search"
    assert_includes body, "Sitemap: https://inantandai.com/sitemap.xml"
  end
end
