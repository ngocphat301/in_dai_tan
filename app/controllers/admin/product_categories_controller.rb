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
      flash_duplicate_blog_post_alert
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    assign_duplicate_blog_post_error
    flash_duplicate_blog_post_alert
    render :new, status: :unprocessable_entity
  end

  def update
    if @product_category.update(product_category_params)
      redirect_to admin_product_categories_path, notice: "Đã cập nhật danh mục."
    else
      flash_duplicate_blog_post_alert
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    assign_duplicate_blog_post_error
    flash_duplicate_blog_post_alert
    render :edit, status: :unprocessable_entity
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
    @service_blog_posts = BlogPost.where(category: :service).order(:title)
  end

  def assign_duplicate_blog_post_error
    @product_category.errors.add(
      :blog_post_id,
      "đã được gán cho một danh mục sản phẩm khác (mỗi bài «Dịch vụ» chỉ gắn một danh mục)"
    )
  end

  def flash_duplicate_blog_post_alert
    msgs = @product_category.errors[:blog_post_id]
    return if msgs.blank?

    dup = msgs.any? { |m| m.to_s.include?("đã được gán cho một danh mục") }
    return unless dup

    flash.now[:alert] = "Bài blog đã được gán cho danh mục khác — chọn bài khác hoặc gỡ gán ở danh mục đang dùng bài này."
  end
end
