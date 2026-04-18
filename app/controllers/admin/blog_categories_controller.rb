class Admin::BlogCategoriesController < Admin::BaseController
  before_action :set_blog_category, only: %i[edit update destroy]

  def index
    @blog_categories = BlogCategory.all
    if (p = admin_like_pattern)
      @blog_categories = @blog_categories.where(
        "blog_categories.name ILIKE :q OR blog_categories.slug ILIKE :q",
        q: p
      )
    end
    @blog_categories = apply_admin_order(
      @blog_categories,
      allowed: %w[position name slug kind created_at updated_at],
      default: "updated_at"
    )
    pag = admin_paginate(@blog_categories)
    @blog_categories = pag[:records]
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def new
    @blog_category = BlogCategory.new(position: (BlogCategory.maximum(:position) || -1) + 1)
  end

  def edit
  end

  def create
    @blog_category = BlogCategory.new(blog_category_params)
    if @blog_category.save
      redirect_to admin_blog_categories_path, notice: "Đã tạo danh mục blog."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog_category.update(blog_category_params)
      redirect_to admin_blog_categories_path, notice: "Đã cập nhật danh mục blog."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog_category.destroy
    redirect_to admin_blog_categories_path, notice: "Đã xóa danh mục blog."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_blog_categories_path, alert: "Không xóa được: còn bài viết thuộc danh mục này."
  end

  private

  def set_blog_category
    @blog_category = BlogCategory.find(params[:id])
  end

  def blog_category_params
    params.require(:blog_category).permit(:name, :slug, :position, :kind)
  end
end
