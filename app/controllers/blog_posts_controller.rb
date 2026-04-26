# frozen_string_literal: true

class BlogPostsController < ApplicationController
  include PaginatedCatalog
  include ServiceBlogQuotePrefill

  before_action :set_blog_post, only: :show
  before_action :prefill_quote_request_for_service_blog, only: :show

  def index
    @blog_list_title = "Tin tức"
    @blog_list_layout = :hub
    scope = blog_posts_base_scope.where.not(category: :project)
    assign_news_hub!(scope)
    @breadcrumbs = [ crumb_root, crumb_current("Tin tức") ]
    render :index
  end

  def service_index
    @blog_list_title = "Dịch vụ in ấn"
    @blog_list_layout = :list
    scope = blog_posts_base_scope.where(category: :service)
    assign_blog_list!(scope, pagination: :service)
    @breadcrumbs = [ crumb_root, crumb_current("Dịch vụ in ấn") ]
    render :index
  end

  def project_index
    @blog_list_title = "Dự án"
    @blog_list_layout = :project_cards
    scope = blog_posts_base_scope.where(category: :project)
    assign_blog_list!(scope, pagination: :project)
    @breadcrumbs = [ crumb_root, crumb_current("Dự án") ]
    render :index
  end

  def show
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
  end

  private

  def set_blog_post
    @blog_post = BlogPost.published_now.includes(:linked_product_category, { avatar_attachment: :blob }).find_by!(slug: params[:slug])
  end

  def blog_posts_base_scope
    BlogPost.published_now.includes(:user, { avatar_attachment: :blob })
  end

  def assign_blog_list!(scope, pagination:)
    pag = paginate_scope(scope)
    @blog_posts = pag[:records]
    @page = pag[:page]
    @per_page = pag[:per]
    @total_pages = pag[:total_pages]
    @total_count = pag[:total_count]
    @prev_path = blog_list_prev_path(pagination, @page)
    @next_path = blog_list_next_path(pagination, @page, pag[:total_pages])
  end

  def blog_list_prev_path(kind, page)
    return nil if page <= 1

    case kind
    when :service then blog_services_path(page: page - 1)
    when :project then blog_projects_path(page: page - 1)
    else blog_posts_path(page: page - 1)
    end
  end

  def blog_list_next_path(kind, page, total_pages)
    return nil if page >= total_pages

    case kind
    when :service then blog_services_path(page: page + 1)
    when :project then blog_projects_path(page: page + 1)
    else blog_posts_path(page: page + 1)
    end
  end

  # Trang tin: tất cả bài (trừ dự án). Trang 1: bài mới nhất nổi bật + lưới các bài còn lại (phân trang theo lưới).
  def assign_news_hub!(scope)
    per = PaginatedCatalog::DEFAULT_PER_PAGE
    per = 12 if per < 1
    total = scope.count
    if total.zero?
      @featured_post = nil
      @blog_posts = BlogPost.none
      @page = 1
      @per_page = per
      @total_pages = 1
      @total_count = 0
      @prev_path = nil
      @next_path = nil
      return
    end

    list_total = total - 1
    total_pages = [ (list_total.to_f / per).ceil, 1 ].max
    page = [ [ params[:page].to_i, 1 ].max, total_pages ].min

    @featured_post = page == 1 ? scope.first : nil
    list_offset = 1 + (page - 1) * per
    @blog_posts = scope.offset(list_offset).limit(per)
    @page = page
    @per_page = per
    @total_pages = total_pages
    @total_count = list_total
    @prev_path = page > 1 ? blog_posts_path(page: page - 1) : nil
    @next_path = page < total_pages ? blog_posts_path(page: page + 1) : nil
  end
end
