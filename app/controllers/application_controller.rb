class ApplicationController < ActionController::Base
  include Breadcrumbs

  allow_browser versions: :modern

  stale_when_importmap_changes

  before_action :load_header_product_categories, if: :html_public_layout?
  before_action :load_ads_popup_data, if: :html_public_layout?
  before_action :prepare_quote_request_for_modal, if: :html_quote_modal_layout?

  helper_method :nav_user, :current_admin?, :quote_modal_open?, :ads_popup_enabled?

  def html_public_layout?
    request.format.html? && !request.path.start_with?("/admin") && !request.path.start_with?("/users")
  end

  # Form báo giá (modal) dùng chung layout kể cả trang đăng nhập — không gắn header danh mục.
  def html_quote_modal_layout?
    return false if request.path.start_with?("/admin")

    # Browser thường gửi text/html; curl/bot hay gửi */* — vẫn render HTML nhưng format.html? là false.
    navigational_html_format = request.format.html? || request.format == Mime::Type.lookup("*/*")
    navigational_html_format
  end

  def load_header_product_categories
    @header_product_categories = Rails.cache.fetch(LayoutCache::HEADER_CATEGORIES_KEY, expires_in: 10.minutes) do
      ProductCategory.ordered.includes(:blog_post).to_a
    end
  rescue ActiveRecord::StatementInvalid
    @header_product_categories = []
  end

  # Dùng thay cho user_signed_in? / current_user trong layout khi không có Warden (mailer, render tách).
  def nav_user
    w = request&.env&.[]("warden")
    return nil unless w.respond_to?(:authenticated?)

    w.user(:user) if w.authenticated?(:user)
  rescue Devise::MissingWarden, NoMethodError
    nil
  end

  def current_admin?
    nav_user&.admin?
  end

  def quote_modal_open?
    defined?(@quote_modal_open) && @quote_modal_open
  end

  def load_ads_popup_data
    # Popup: bài blog thuộc danh mục loại «quảng cáo» (avatar → ảnh popup, không còn SiteImage riêng).
    @ads_popup_preview = Rails.env.development? && params[:ads_preview].to_s == "1"
    @ads_popup_post = Rails.cache.fetch(LayoutCache::ADS_POPUP_KEY, expires_in: 10.minutes) do
      BlogPost.published_now
        .where(category: :ads)
        .includes(avatar_attachment: :blob)
        .order(published_at: :desc)
        .first
    end
    @ads_popup_title = @ads_popup_post&.title.presence ||
      "Để lại số điện thoại — chúng tôi liên hệ tư vấn"
    @ads_popup_enabled = @ads_popup_post.present?
    if Rails.env.development?
      Rails.logger.info(
        "[ads_popup] enabled=#{@ads_popup_enabled} " \
        "post_ads=#{@ads_popup_post.present?} " \
        "avatar=#{@ads_popup_post&.avatar&.attached?} preview=#{@ads_popup_preview}"
      )
    end
  rescue ActiveRecord::StatementInvalid
    @ads_popup_enabled = false
  end

  def ads_popup_enabled?
    @ads_popup_enabled == true
  end

  def prepare_quote_request_for_modal
    @quote_return_to ||= "home"
    @quote_request ||= QuoteRequest.new
  end
end
