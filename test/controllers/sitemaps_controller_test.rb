# frozen_string_literal: true

require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "index returns urlset with core urls" do
    get "/sitemap.xml"
    assert_response :success
    body = response.body
    assert_includes body, "http://www.sitemaps.org/schemas/sitemap/0.9"
    assert_includes body, "<urlset"
    assert_match %r{<loc>http://www\.example\.com/</loc>}, body
    assert_match %r{/blog</loc>}, body
  end
end
