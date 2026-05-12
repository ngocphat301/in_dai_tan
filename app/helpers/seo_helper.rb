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
    graph << @seo_json_ld_extra if @seo_json_ld_extra.present?

    { "@context" => "https://schema.org", "@graph" => graph }
  end
end
