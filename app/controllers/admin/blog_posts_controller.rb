class Admin::BlogPostsController < Admin::BaseController
  before_action :set_blog_post, only: %i[show edit update destroy toggle_status]

  def index
    @blog_posts = BlogPost.all.includes(:user, { avatar_attachment: :blob })
    if (cat = params[:category].presence_in(BlogPost.categories.keys))
      @blog_posts = @blog_posts.where(category: cat)
    end
    if (p = admin_like_pattern)
      @blog_posts = @blog_posts.where(
        <<~SQL.squish,
          blog_posts.title ILIKE :q OR blog_posts.slug ILIKE :q
          OR COALESCE(blog_posts.excerpt, '') ILIKE :q
          OR COALESCE(blog_posts.meta_title, '') ILIKE :q
          OR COALESCE(blog_posts.meta_description, '') ILIKE :q
        SQL
        q: p
      )
    end
    @blog_posts = apply_admin_order(
      @blog_posts,
      allowed: %w[title slug status published_at updated_at created_at],
      default: "updated_at"
    )
    pag = admin_paginate(@blog_posts)
    @blog_posts = pag[:records]
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def show
  end

  def new
    @blog_post = BlogPost.new(status: :hidden, category: :news)
  end

  def edit
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.user = current_user
    if @blog_post.save
      redirect_to admin_blog_post_path(@blog_post), notice: "Đã tạo bài viết."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_post_path(@blog_post), notice: "Đã cập nhật bài viết."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "Đã xóa bài viết."
  end

  def toggle_status
    new_status = @blog_post.publish? ? :hidden : :publish
    @blog_post.update!(status: new_status)
    redirect_back fallback_location: admin_blog_posts_path, notice: (@blog_post.publish? ? "Đã chuyển sang xuất bản." : "Đã chuyển sang ẩn.")
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(
      :title,
      :slug,
      :excerpt,
      :body,
      :meta_title,
      :meta_description,
      :status,
      :category,
      :published_at,
      :avatar,
      :tag_list
    )
  end
end
