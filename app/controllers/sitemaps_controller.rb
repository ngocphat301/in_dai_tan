# frozen_string_literal: true

# Sitemap XML cho công cụ tìm kiếm (URL tĩnh + blog + sản phẩm đã xuất bản).
class SitemapsController < ApplicationController
  layout false

  def index
    @urls = sitemap_entries
    respond_to { |format| format.xml }
  end

  private

  def sitemap_entries
    posts = BlogPost.published_now.pluck(:slug, :updated_at)
    products = Product.published_list.pluck(:id, :updated_at)
    last_site = (posts.map(&:last) + products.map(&:last)).compact.max

    entries = []
    entries << static_entry(root_url, priority: 1.0, changefreq: "daily", lastmod: last_site)
    entries << static_entry(about_url, priority: 0.6, changefreq: "monthly")
    entries << static_entry(contact_url, priority: 0.6, changefreq: "monthly")
    entries << static_entry(products_url, priority: 0.85, changefreq: "daily", lastmod: last_site)
    entries << static_entry(blog_posts_url, priority: 0.9, changefreq: "daily", lastmod: last_site)
    entries << static_entry(blog_services_url, priority: 0.85, changefreq: "weekly", lastmod: last_site)
    entries << static_entry(blog_projects_url, priority: 0.85, changefreq: "weekly", lastmod: last_site)

    posts.each do |slug, updated_at|
      entries << {
        loc: blog_post_url(slug),
        changefreq: "weekly",
        priority: 0.8,
        lastmod: updated_at
      }
    end

    products.each do |id, updated_at|
      entries << {
        loc: product_url(id),
        changefreq: "weekly",
        priority: 0.75,
        lastmod: updated_at
      }
    end

    entries
  end

  def static_entry(loc, priority:, changefreq:, lastmod: nil)
    { loc:, priority:, changefreq:, lastmod: }.compact
  end
end
