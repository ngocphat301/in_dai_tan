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

  test "blog show includes article OG, BlogPosting and BreadcrumbList" do
    get blog_post_path("published-seo-news")

    assert_response :success
    assert_select 'meta[name="description"][content*="fixture"]', count: 1
    assert_select 'meta[property="article:published_time"]', count: 1
    assert_select 'meta[property="article:modified_time"]', count: 1
    assert_includes response.body, "\"@type\":\"BlogPosting\""
    assert_includes response.body, "\"@type\":\"BreadcrumbList\""
  end

  test "blog index includes ItemList json ld" do
    get blog_posts_path

    assert_response :success
    assert_includes response.body, "\"@type\":\"ItemList\""
    assert_includes response.body, "published-seo-news"
  end

  test "products index includes ItemList json ld" do
    get products_path

    assert_response :success
    assert_includes response.body, "\"@type\":\"ItemList\""
    assert_includes response.body, "published-seo-product-post"
  end

  test "product show includes BreadcrumbList json ld" do
    product = products(:published_product)

    get product_path(product)

    assert_response :success
    assert_includes response.body, "\"@type\":\"Product\""
    assert_includes response.body, "\"@type\":\"BreadcrumbList\""
  end
end
