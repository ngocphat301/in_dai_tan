module ApplicationHelper
  include ActionView::Helpers::TextHelper

  # Bôi <mark> các đoạn trùng từ khóa (an toàn HTML).
  def search_highlight(text, query)
    phrases = query.to_s.split(/\s+/).reject(&:blank?).uniq
    return ERB::Util.html_escape(text.to_s).html_safe if phrases.empty?

    highlight(text.to_s, phrases, highlighter: '<mark class="dm-search-hit">\1</mark>')
  end

  # Nhóm [ [ tên danh mục, [ [ tên SP, id ], ... ] ], ... ] cho grouped_options_for_select
  def social_facebook_url
    ENV.fetch("SOCIAL_FACEBOOK_URL", "https://www.facebook.com/baobitandai")
  end

  # Chỉ chữ số, mặc định hotline Zalo / gọi / WhatsApp (góc phải màn hình).
  def social_hotline
    ENV.fetch("SOCIAL_HOTLINE", "0898387281").gsub(/\D/, "")
  end

  def social_hotline_tel
    "tel:#{social_hotline}"
  end

  # Hiển thị: 0898 387 281
  def social_hotline_display
    s = social_hotline
    return s if s.length != 10

    "#{s[0..3]} #{s[4..6]} #{s[7..9]}"
  end

  def social_zalo_chat_url
    ENV.fetch("SOCIAL_ZALO_URL", "https://zalo.me/#{social_hotline}")
  end

  def social_whatsapp_url
    url = ENV["SOCIAL_WHATSAPP_URL"].presence
    return url if url.present?

    rest = social_hotline.sub(/\A0/, "")
    "https://wa.me/84#{rest}"
  end

  # Logo thương hiệu (header + đăng nhập). Mặc định: Google Drive — file cần bật «Ai có liên kết đều xem được».
  # Ghi đè: ENV["SITE_BRAND_LOGO_URL"] hoặc URL trực tiếp tải ảnh.
  def site_brand_logo_url
    ENV.fetch(
      "SITE_BRAND_LOGO_URL",
      "https://drive.google.com/thumbnail?id=1nDB2EV1oe02c-rGQtzsTfT3qT0fxn-6i&sz=w800"
    )
  end

  def published_products_grouped_options_for_select
    ProductCategory.ordered.includes(:products).filter_map do |cat|
      items = cat.products.select(&:published?).sort_by(&:name).map { |p| [ p.name, p.id ] }
      next if items.empty?

      [ cat.name, items ]
    end
  end

  # Danh mục sản phẩm (catalog) — chọn trong form báo giá.
  def product_categories_for_quote_select
    ProductCategory.ordered
  end

  # Đích khi bấm tên danh mục ở menu "Dịch vụ in" / lọc sản phẩm:
  # - đã gắn bài blog Dịch vụ và bài đang xuất bản → trang bài viết
  # - không gắn hoặc bài chưa công khai → trang danh mục sản phẩm
  def product_category_nav_url(category)
    post = category.blog_post
    if post&.published_for_public?
      blog_post_path(post.slug)
    else
      products_path(category: category.slug)
    end
  end

  def header_search_placeholder
    "Tìm bài viết đã xuất bản…"
  end

  # Menu «Tin tức» — chỉ danh sách bài loại tin tức (/blog).
  def blog_news_index_path
    blog_posts_path
  end

  def nav_active?(key)
    case key
    when :services_mega
      controller_name == "home" && params[:category].present?
    when :products
      false
    when :blog
      # «Tin tức»: danh sách tin; không highlight Dịch vụ / Dự án / Sản phẩm (có đích hoặc mục riêng).
      if controller_name == "blog_posts" && %w[project_index service_index].include?(action_name)
        false
      elsif controller_name == "blog_posts" && action_name == "show" && @blog_post&.category_project?
        false
      elsif controller_name == "blog_posts" && action_name == "show" && @blog_post&.category_product?
        params[:news_context].present?
      elsif controller_name == "searches" && params[:kind].to_s != "product"
        true
      else
        controller_name == "blog_posts"
      end
    when :blog_projects
      (controller_name == "blog_posts" && action_name == "project_index") ||
        (controller_name == "blog_posts" && action_name == "show" && @blog_post&.category_project?)
    when :about
      controller_name == "pages" && action_name == "about"
    when :contact
      controller_name == "pages" && action_name == "contact"
    else
      false
    end
  end

  # Ảnh đại diện bài blog — nếu chưa có avatar, dùng nền trắng mặc định (blog_avatar_placeholder.svg).
  def blog_post_avatar_tag(blog_post, variant:, alt: nil, **html_options)
    alt_text = alt.presence || blog_post.title
    opts = html_options.merge(alt: alt_text)
    if blog_post.avatar.attached?
      image_tag blog_post.avatar.variant(variant), **opts
    else
      image_tag "blog_avatar_placeholder.svg", **opts
    end
  end

  def nav_link_class(key, base = "dm-nav__link")
    [ base, ("is-active" if nav_active?(key)) ].compact.join(" ")
  end

  def nav_trigger_class(key, base = "dm-nav__trigger")
    [ base, ("is-active" if nav_active?(key)) ].compact.join(" ")
  end

  # Breadcrumb cho trang bài blog (dùng lại khi render lỗi form báo giá).
  def blog_post_breadcrumbs(post, news_context: nil)
    news_context = params[:news_context].present? if news_context.nil?
    trail = [ { label: "Trang chủ", path: root_path } ]
    case post.category
    when "service"
      trail << { label: "Dịch vụ in ấn", path: blog_services_path }
    when "product"
      if news_context
        trail << { label: "Tin tức", path: blog_posts_path }
      else
        trail << { label: "Sản phẩm", path: products_path }
      end
    when "news"
      trail << { label: "Tin tức", path: blog_posts_path }
    when "project"
      trail << { label: "Dự án", path: blog_projects_path }
    when "factory_scale"
      trail << { label: "Quy mô xưởng in", path: root_path(anchor: "dm-factory-scale") }
    when "ads"
      trail << { label: "Tin tức", path: blog_posts_path }
    when "partners"
      trail << { label: "Đối tác", path: root_path(anchor: "dm-partners") }
    end
    trail << { label: post.title.truncate(72), path: nil }
    trail
  end

  # JSON-LD ItemList cho khối «Quy mô xưởng in» (Rich Results / hiểu thị nội dung).
  def factory_scale_itemlist_json_ld(blog_posts)
    list = blog_posts.respond_to?(:to_a) ? blog_posts.to_a : []
    return ActiveSupport::SafeBuffer.new if list.blank?

    data = {
      "@context" => "https://schema.org",
      "@type" => "ItemList",
      "name" => "Quy mô xưởng in — In Tân Đại",
      "description" => "Giới thiệu trang thiết bị và năng lực sản xuất in ấn tại xưởng.",
      "numberOfItems" => list.size,
      "itemListElement" => list.map.with_index(1) do |post, i|
        {
          "@type" => "ListItem",
          "position" => i,
          "name" => post.title,
          "url" => blog_post_url(post.slug)
        }
      end
    }
    content_tag(:script, raw(ERB::Util.json_escape(data.to_json)), type: "application/ld+json")
  end
end
