# frozen_string_literal: true

require "test_helper"

class SeoPublicPagesTest < ActionDispatch::IntegrationTest
  test "root includes canonical and og tags" do
    get root_path

    assert_response :success
    assert_select 'link[rel="canonical"][href^="http"]', count: 1
    assert_select 'meta[property="og:title"][content*="Trang chủ"]', count: 1
    assert_select 'script[type="application/ld+json"]', minimum: 1
  end

  test "blog show includes BlogPosting json ld" do
    get blog_post_path("published-seo-news")

    assert_response :success
    assert_select 'meta[name="description"][content*="fixture"]', count: 1
    assert_includes response.body, "\"@type\":\"BlogPosting\""
  end

  test "product show includes Product json ld" do
    product = products(:published_product)

    get product_path(product)

    assert_response :success
    assert_includes response.body, "\"@type\":\"Product\""
  end
end
