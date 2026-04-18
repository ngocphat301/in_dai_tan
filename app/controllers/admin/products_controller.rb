class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[show edit update destroy toggle_published]

  def index
    @products = Product.includes(:product_category, images: { file_attachment: :blob })
    if (p = admin_like_pattern)
      @products = @products.where(
        "products.name ILIKE :q OR COALESCE(products.description, '') ILIKE :q",
        q: p
      )
    end
    @products = apply_admin_order(@products, allowed: %w[name created_at updated_at sale_price_vnd], default: "updated_at")
    pag = admin_paginate(@products)
    @products = pag[:records]
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def show
  end

  def new
    @product = Product.new(product_category_id: ProductCategory.ordered.first&.id)
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_product_path(@product), notice: "Đã tạo sản phẩm."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: "Đã cập nhật sản phẩm."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Đã xóa sản phẩm."
  end

  def toggle_published
    @product.update!(published: !@product.published)
    redirect_back fallback_location: admin_products_path, notice: (@product.published? ? "Đã bật hiển thị." : "Đã tắt hiển thị.")
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :sale_price_vnd,
      :original_price_vnd,
      :promo_starts_at,
      :promo_ends_at,
      :published,
      :product_category_id
    )
  end
end
