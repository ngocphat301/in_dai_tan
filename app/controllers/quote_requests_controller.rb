# frozen_string_literal: true

class QuoteRequestsController < ApplicationController
  include HomePageData
  include ServiceBlogQuotePrefill

  def create
    @quote_return_to = params[:return_to].presence_in(%w[home contact product blog]) || "home"
    @quote_request = QuoteRequest.new(quote_request_params)

    if @quote_request.save
      dest = quote_success_redirect_path
      redirect_to dest, notice: "Cảm ơn bạn! Chúng tôi đã nhận yêu cầu báo giá và sẽ liên hệ sớm."
    else
      @quote_modal_open = true
      flash.now[:alert] = "Vui lòng kiểm tra lại thông tin gửi báo giá."
      case @quote_return_to
      when "contact"
        render "pages/contact", status: :unprocessable_entity
      when "product"
        render_product_show_for_quote_errors
      when "blog"
        render_blog_show_for_quote_errors
      else
        load_home_page_data
        render "home/index", status: :unprocessable_entity
      end
    end
  end

  private

  def quote_success_redirect_path
    case @quote_return_to
    when "contact" then contact_path
    when "product"
      if @quote_request.product_id.present?
        product_path(@quote_request.product_id)
      elsif @quote_request.product_category_id.present?
        products_path
      elsif @quote_request.blog_post_id.present? && (slug = BlogPost.find_by(id: @quote_request.blog_post_id)&.slug)
        blog_post_path(slug)
      else
        root_path
      end
    when "blog"
      if @quote_request.blog_post_id.present? && (slug = BlogPost.find_by(id: @quote_request.blog_post_id)&.slug)
        blog_post_path(slug)
      else
        root_path
      end
    else
      root_path
    end
  end

  def render_blog_show_for_quote_errors
    @blog_post = BlogPost.published_now.includes(:linked_product_category, { avatar_attachment: :blob }).find_by(id: @quote_request.blog_post_id)
    if @blog_post
      @breadcrumbs = helpers.blog_post_breadcrumbs(@blog_post, news_context: params[:news_context].present?)
      if @blog_post.category_service?
        @related_product_posts = @blog_post.related_product_blog_posts(limit: 6)
        @related_blog_posts = []
        @related_project_posts = []
        @blog_post_html, @blog_outline = helpers.blog_post_outline_and_html(@blog_post)
      elsif @blog_post.category_project?
        @related_product_posts = []
        @related_blog_posts = []
        @related_project_posts = @blog_post.related_project_posts(limit: 6)
        @blog_post_html, @blog_outline = helpers.blog_post_outline_and_html(@blog_post)
      else
        @related_product_posts = []
        @related_project_posts = []
        @related_blog_posts = @blog_post.related_blog_posts(limit: 6)
        @blog_post_html, @blog_outline = helpers.blog_post_outline_and_html(@blog_post)
      end
      prefill_quote_request_for_service_blog
      render "blog_posts/show", status: :unprocessable_entity
    else
      load_home_page_data
      render "home/index", status: :unprocessable_entity
    end
  end

  def render_product_show_for_quote_errors
    @product = Product.published_list.includes(:product_category, images: { file_attachment: :blob }).find_by(id: @quote_request.product_id)
    @product ||= Product.published_list.includes(:product_category, images: { file_attachment: :blob }).find_by(product_category_id: @quote_request.product_category_id)
    @product ||= begin
      pc = ProductCategory.find_by(blog_post_id: @quote_request.blog_post_id)
      pc&.products&.published_list&.includes(:product_category, images: { file_attachment: :blob })&.first
    end
    if @product
      @quote_return_to = "product"
      render "products/show", status: :unprocessable_entity
    else
      load_home_page_data
      render "home/index", status: :unprocessable_entity
    end
  end

  def quote_request_params
    params.require(:quote_request).permit(:customer_name, :phone, :product_category_id, :blog_post_id, :body)
  end
end
