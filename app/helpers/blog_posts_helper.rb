# frozen_string_literal: true

module BlogPostsHelper
  BLOG_POST_EXTERNAL_LINK_REL = "nofollow noopener noreferrer"

  # Link bài trong khối «Bài viết liên quan» (giống layout dịch vụ): bài loại sản phẩm → ?news_context=1.
  def blog_post_related_path(post)
    post.category_product? ? blog_post_path(post.slug, news_context: 1) : blog_post_path(post.slug)
  end

  # Gắn id cho h1/h2/h3 trong nội dung (thẻ HTML ngữ nghĩa), rel cho link ngoài, mảng mục lục { level:, text:, id: }.
  def blog_post_outline_and_html(blog_post)
    return [ nil, [] ] unless blog_post.body.present?

    html = blog_post_body_html(blog_post)
    return [ nil, [] ] if html.blank?

    processed_html, outline = blog_post_process_content_html(html)
    [ processed_html.html_safe, outline ]
  rescue StandardError
    html = blog_post_body_html(blog_post)
    return [ nil, [] ] if html.blank?

    [ blog_post_harden_content_links_html(html).html_safe, [] ]
  end

  private

  def blog_post_body_html(blog_post)
    rt = blog_post.body
    if rt.respond_to?(:body) && rt.body.respond_to?(:to_html)
      rt.body.to_html
    elsif rt.respond_to?(:to_html)
      rt.to_html
    else
      rt.to_s
    end
  end

  def blog_post_process_content_html(html)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    outline = []
    idx = 0
    doc.css("h1, h2, h3").each do |node|
      idx += 1
      slug = node["id"].presence
      if slug.blank?
        slug = "#{node.name.downcase}-#{idx}-#{node.text.to_s.parameterize}"[0, 180]
        node["id"] = slug
      end
      outline << { level: node.name.downcase, text: node.text.strip, id: slug }
    end
    blog_post_harden_content_links!(doc)
    [ doc.to_html, outline ]
  end

  def blog_post_harden_content_links_html(html)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    blog_post_harden_content_links!(doc)
    doc.to_html
  end

  def blog_post_harden_content_links!(doc)
    doc.css("a[href]").each do |anchor|
      href = anchor["href"].to_s.strip
      next if href.blank?
      next unless blog_post_external_link?(href)

      anchor["target"] = "_blank"
      anchor["rel"] = blog_post_merge_link_rel(anchor["rel"], BLOG_POST_EXTERNAL_LINK_REL)
    end
  end

  def blog_post_external_link?(href)
    return false if href.start_with?("#", "mailto:", "tel:", "javascript:")
    return false unless href.match?(%r{\Ahttps?://}i)

    host = URI.parse(href).host&.downcase
    host.present? && !blog_post_internal_link_host?(host)
  rescue URI::InvalidURIError
    false
  end

  def blog_post_internal_link_host?(host)
    blog_post_internal_link_hosts.include?(host.downcase)
  end

  def blog_post_internal_link_hosts
    hosts = %w[inantandai.com www.inantandai.com]
    hosts << request.host.downcase if respond_to?(:request) && request&.host.present?
    app_host = ENV["APP_HOST"].presence
    hosts << app_host.downcase if app_host.present?
    hosts.compact.uniq
  end

  def blog_post_merge_link_rel(existing, required)
    (existing.to_s.split + required.split).map(&:downcase).uniq.join(" ")
  end
end
