# frozen_string_literal: true

module BlogPostsHelper
  # Link bài trong khối «Bài viết liên quan» (giống layout dịch vụ): bài loại sản phẩm → ?news_context=1.
  def blog_post_related_path(post)
    post.category_product? ? blog_post_path(post.slug, news_context: 1) : blog_post_path(post.slug)
  end

  # Gắn id cho h2/h3 trong nội dung Trix và trả về mảng mục lục { level:, text:, id: }.
  def blog_post_outline_and_html(blog_post)
    return [ nil, [] ] unless blog_post.body.present?

    rt = blog_post.body
    html = if rt.respond_to?(:body) && rt.body.respond_to?(:to_html)
      rt.body.to_html
    elsif rt.respond_to?(:to_html)
      rt.to_html
    else
      rt.to_s
    end
    return [ nil, [] ] if html.blank?
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    outline = []
    idx = 0
    doc.css("h2, h3").each do |node|
      idx += 1
      slug = node["id"].presence
      if slug.blank?
        slug = "#{node.name.downcase}-#{idx}-#{node.text.to_s.parameterize}"[0, 180]
        node["id"] = slug
      end
      outline << { level: node.name.downcase, text: node.text.strip, id: slug }
    end
    [ doc.to_html.html_safe, outline ]
  rescue StandardError
    fb = blog_post.body
    raw = if fb.respond_to?(:body) && fb.body.respond_to?(:to_html)
      fb.body.to_html
    elsif fb.respond_to?(:to_html)
      fb.to_html
    else
      fb.to_s
    end
    [ raw.html_safe, [] ]
  end
end
