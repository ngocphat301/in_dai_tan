class Admin::ProductCategoriesController < Admin::BaseController
  before_action :set_product_category, only: %i[edit update destroy]
  before_action :load_service_blog_posts, only: %i[new edit create update]

  def index
    @product_categories = ProductCategory.all.includes(:blog_post)
    if (p = admin_like_pattern)
      @product_categories = @product_categories.where(
        "product_categories.name ILIKE :q OR product_categories.slug ILIKE :q",
        q: p
      )
    end
    @product_categories = apply_admin_order(
      @product_categories,
      allowed: %w[position name slug created_at updated_at],
      default: "updated_at"
    )
    pag = admin_paginate(@product_categories)
    @product_categories = pag[:records]
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def new
    @product_category = ProductCategory.new(position: (ProductCategory.maximum(:position) || -1) + 1)
  end

  def edit
  end

  def create
    @product_category = ProductCategory.new(product_category_params)
    if @product_category.save
      redirect_to admin_product_categories_path, notice: "Đã tạo danh mục."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product_category.update(product_category_params)
      redirect_to admin_product_categories_path, notice: "Đã cập nhật danh mục."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product_category.destroy
    redirect_to admin_product_categories_path, notice: "Đã xóa danh mục."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_product_categories_path, alert: "Không xóa được: còn sản phẩm thuộc danh mục này."
  end

  private

  def set_product_category
    @product_category = ProductCategory.find(params[:id])
  end

  def product_category_params
    params.require(:product_category).permit(:name, :slug, :position, :blog_post_id)
  end

  def load_service_blog_posts
    @service_blog_posts = BlogPost.joins(:blog_category).where(blog_categories: { slug: "service" }).order(:title)
  end
end
