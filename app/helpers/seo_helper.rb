# frozen_string_literal: true

module SeoHelper
  include ApplicationHelper
  include ProductsHelper

  SEO_DESCRIPTION_MAX = 300

  def seo_truncate_description(text, max = SEO_DESCRIPTION_MAX)
    truncate(text.to_s.strip, length: max, omission: "…")
  end

  def seo_site_origin(request)
    host = ENV["CANONICAL_HOST"].presence
    return "https://#{host}" if host.present?

    "#{request.scheme}://#{request.host_with_port}"
  end

  def seo_current_canonical_url(request)
    "#{seo_site_origin(request)}#{request.fullpath}"
  end

  def seo_default_og_image_url(request)
    ENV["SEO_DEFAULT_OG_IMAGE_URL"].presence || site_brand_logo_url
  end

  # URL tuyệt đối cho avatar blog (ActiveStorage); fallback logo site.
  def seo_blog_og_image_url(blog_post, request)
    return seo_default_og_image_url(request) unless blog_post.avatar.attached?

    host = ENV["CANONICAL_HOST"].presence || request.host_with_port
    protocol = ENV["CANONICAL_HOST"].present? ? "https" : request.scheme

    Rails.application.routes.url_helpers.rails_blob_url(
      blog_post.avatar,
      host: host,
      protocol: protocol
    )
  rescue StandardError
    seo_default_og_image_url(request)
  end

  def seo_product_og_image_url(product, request)
    first = product_gallery_items(product).first
    return seo_default_og_image_url(request) unless first

    url = first[:url].to_s
    return url if url.start_with?("http://", "https://")

    "#{seo_site_origin(request)}#{url}"
  rescue StandardError
    seo_default_og_image_url(request)
  end

  def json_ld_escape(data)
    raw(ERB::Util.json_escape(data.to_json))
  end

  def seo_json_ld_graph(_seo, request:)
    origin = seo_site_origin(request)
    site_name = "In Tân Đại"
    hotline = social_hotline.to_s
    intl_phone = if hotline.present?
      "+84-#{hotline.sub(/\A0/, "")}"
    end

    org = {
      "@type" => "Organization",
      "name" => "Công ty TNHH tổng hợp sản xuất và thương mại Tân Đại",
      "alternateName" => site_name,
      "url" => origin,
      "logo" => seo_default_og_image_url(request),
      "telephone" => intl_phone,
      "email" => "inantandai@gmail.com",
      "address" => {
        "@type" => "PostalAddress",
        "streetAddress" => "Số 39 Xuân Khôi, Cự Khối, Long Biên",
        "addressLocality" => "Hà Nội",
        "addressCountry" => "VN"
      }
    }.compact

    web_site = {
      "@type" => "WebSite",
      "name" => site_name,
      "url" => origin
    }

    graph = [ org, web_site ]
    seo_json_ld_extra_nodes.each { |node| graph << node }

    { "@context" => "https://schema.org", "@graph" => graph }
  end

  # Một hoặc nhiều node JSON-LD (ví dụ BlogPosting + BreadcrumbList).
  def seo_json_ld_extra_nodes
    case @seo_json_ld_extra
    when nil then []
    when Array then @seo_json_ld_extra.compact
    else [ @seo_json_ld_extra ]
    end
  end

  def seo_absolute_url_from_path(request, path)
    p = path.to_s
    return p if p.start_with?("http://", "https://")

    base = seo_site_origin(request)
    p = "/#{p.delete_prefix('/')}"
    "#{base}#{p}"
  end

  # crumbs: [{ label:, path: }], path nil = trang hiện tại (dùng page_url).
  def seo_breadcrumb_list_json_ld(crumbs, request, page_url:)
    return nil if crumbs.blank?

    elements = crumbs.each_with_index.map do |c, idx|
      item_url =
        if c[:path].present?
          seo_absolute_url_from_path(request, c[:path])
        else
          page_url
        end
      {
        "@type" => "ListItem",
        "position" => idx + 1,
        "name" => c[:label].to_s,
        "item" => item_url
      }
    end
    return nil if elements.blank?

    { "@type" => "BreadcrumbList", "itemListElement" => elements }
  end

  # ItemList các bài blog (trang danh sách tin / dịch vụ / dự án hoặc /products).
  def seo_blog_post_item_list_json_ld(posts, request, name:, description:)
    list = Array(posts).compact
    return nil if list.empty?

    routes = Rails.application.routes.url_helpers
    {
      "@type" => "ItemList",
      "name" => name,
      "description" => seo_truncate_description(description),
      "numberOfItems" => list.size,
      "itemListElement" => list.each_with_index.map do |post, i|
        {
          "@type" => "ListItem",
          "position" => i + 1,
          "name" => post.title,
          "url" => seo_absolute_url_from_path(request, routes.blog_post_path(post.slug))
        }
      end
    }
  end

  # Google BlogPosting — author, publisher, mainEntityOfPage, dateModified, inLanguage.
  def seo_blog_posting_structured_data(blog_post, request, canonical:, description:)
    published = blog_post.published_at
    img_url = seo_blog_og_image_url(blog_post, request)
    {
      "@type" => "BlogPosting",
      "headline" => blog_post.title,
      "description" => description,
      "url" => canonical,
      "datePublished" => published&.iso8601,
      "dateModified" => blog_post.updated_at.iso8601,
      "inLanguage" => "vi",
      "mainEntityOfPage" => {
        "@type" => "WebPage",
        "@id" => canonical
      },
      "image" => [ img_url ],
      "author" => {
        "@type" => "Person",
        "name" => blog_post.user&.quote_display_name.presence || "In Tân Đại"
      },
      "publisher" => {
        "@type" => "Organization",
        "name" => "In Tân Đại",
        "logo" => {
          "@type" => "ImageObject",
          "url" => seo_default_og_image_url(request)
        }
      }
    }.compact
  end
end
