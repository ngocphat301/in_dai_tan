# frozen_string_literal: true

class Admin::SiteImagesController < Admin::BaseController
  before_action :set_site_image, only: %i[edit update destroy]

  def index
    scope = SiteImage.includes(file_attachment: :blob)
    scope = scope.where(category: params[:category]) if params[:category].present? && SiteImage.categories.key?(params[:category])
    if (p = admin_like_pattern)
      scope = scope.where(
        <<~SQL.squish,
          COALESCE(site_images.alt_text, '') ILIKE :q
          OR COALESCE(site_images.link_url, '') ILIKE :q
          OR COALESCE(site_images.popup_title, '') ILIKE :q
        SQL
        q: p
      )
    end
    scope = apply_admin_order(scope, allowed: %w[category position published created_at updated_at], default: "updated_at")
    pag = admin_paginate(scope)
    @site_images = pag[:records]
    @category_filter = params[:category].presence
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def new
    @site_image = SiteImage.new(
      category: params[:category].presence_in(SiteImage.categories.keys) || "banner",
      position: (SiteImage.maximum(:position) || -1) + 1,
      published: true
    )
  end

  def edit
  end

  def create
    @site_image = SiteImage.new(site_image_params)
    if @site_image.save
      redirect_to admin_site_images_path, notice: "Đã thêm ảnh."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @site_image.update(site_image_params)
      redirect_to admin_site_images_path, notice: "Đã cập nhật ảnh."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @site_image.destroy
    redirect_to admin_site_images_path, notice: "Đã xóa ảnh."
  end

  private

  def set_site_image
    @site_image = SiteImage.find(params[:id])
  end

  def site_image_params
    params.require(:site_image).permit(:category, :position, :published, :link_url, :alt_text, :popup_title, :file, :mobile_file)
  end
end
