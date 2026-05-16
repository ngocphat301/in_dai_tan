# frozen_string_literal: true

require "test_helper"

class BlogPostsHelperTest < ActionView::TestCase
  test "blog_post_outline_and_html adds rel to external links" do
    post = stub_blog_post_html(
      '<p>Xem <a href="https://example.com/page">đây</a>.</p>'
    )

    html, = blog_post_outline_and_html(post)

    assert_includes html, 'rel="nofollow noopener noreferrer"'
    assert_includes html, 'target="_blank"'
  end

  test "blog_post_outline_and_html keeps internal relative links unchanged" do
    post = stub_blog_post_html(
      '<p><a href="/blog/khac">Bài khác</a></p>'
    )

    html, = blog_post_outline_and_html(post)

    assert_not_includes html, "nofollow"
    assert_not_includes html, 'target="_blank"'
  end

  test "blog_post_outline_and_html keeps inantandai.com links unchanged" do
    post = stub_blog_post_html(
      '<p><a href="https://inantandai.com/dich-vu/">Dịch vụ</a></p>'
    )

    html, = blog_post_outline_and_html(post)

    assert_not_includes html, "nofollow"
  end

  test "blog_post_outline_and_html keeps semantic h1 h2 h3 tags and builds outline" do
    post = stub_blog_post_html(
      "<h1>Mục H1</h1><h2>Mục H2</h2><h3>Mục H3</h3><p>Đoạn văn</p>"
    )

    html, outline = blog_post_outline_and_html(post)

    assert_includes html, "<h1"
    assert_includes html, "<h2"
    assert_includes html, "<h3"
    assert_not_includes html, "<strong>Mục H1</strong>"
    assert_equal 3, outline.size
    assert_equal "h1", outline[0][:level]
    assert_equal "Mục H1", outline[0][:text]
    assert_equal "h2", outline[1][:level]
    assert_equal "h3", outline[2][:level]
  end

  test "blog_post_outline_and_html merges existing rel tokens" do
    post = stub_blog_post_html(
      '<a href="https://other.test/x" rel="noopener" target="_blank">Go</a>'
    )

    html, = blog_post_outline_and_html(post)

    assert_includes html, "nofollow"
    assert_includes html, "noopener"
    assert_includes html, "noreferrer"
  end

  private

  def stub_blog_post_html(html)
    body = Struct.new(:present?, :to_html).new(true, html)
    Struct.new(:body).new(body)
  end
end
