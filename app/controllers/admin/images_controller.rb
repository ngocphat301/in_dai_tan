class Admin::ImagesController < Admin::BaseController
  before_action :set_product
  before_action :set_image, only: %i[edit update destroy]

  def new
    unless @product.images.count < Image::MAX_IMAGES_PER_PRODUCT
      redirect_to admin_product_path(@product), alert: "Đã đủ #{Image::MAX_IMAGES_PER_PRODUCT} ảnh (1 đại diện + 4 đi kèm)."
      return
    end
    @image = @product.images.build(kind: default_kind_for_new)
    assign_image_form_hints
  end

  def create
    assign_image_form_hints
    kind = image_params[:kind].to_s
    gallery_files = Array.wrap(image_params[:gallery_files]).compact_blank

    if kind == "gallery" && gallery_files.any?
      create_gallery_many(gallery_files)
      return
    end

    @image = @product.images.build(image_params.except(:gallery_files))
    if @image.save
      redirect_to admin_product_path(@product), notice: "Đã thêm ảnh."
    else
      assign_image_form_hints
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    assign_image_form_hints
  end

  def update
    if @image.update(image_params.except(:gallery_files))
      redirect_to admin_product_path(@product), notice: "Đã cập nhật ảnh."
    else
      assign_image_form_hints
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image.destroy
    redirect_to admin_product_path(@product), notice: "Đã xóa ảnh."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_image
    @image = @product.images.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:file, :caption, :position, :kind, gallery_files: [])
  end

  def create_gallery_many(files)
    remaining = Image::MAX_IMAGES_PER_PRODUCT - @product.images.count
    if remaining <= 0
      redirect_to admin_product_path(@product), alert: "Đã đủ #{Image::MAX_IMAGES_PER_PRODUCT} ảnh."
      return
    end

    files = files.first(remaining)
    caption = image_params[:caption].to_s
    base_pos = @product.images.maximum(:position).to_i + 1

    @product.transaction do
      files.each_with_index do |upload, i|
        img = @product.images.build(kind: :gallery, caption: caption, position: base_pos + i)
        img.file.attach(upload)
        img.save!
      end
    end

    redirect_to admin_product_path(@product), notice: "Đã thêm #{files.size} ảnh đi kèm."
  rescue ActiveRecord::RecordInvalid => e
    failed = e.record
    @image = @product.images.build(kind: :gallery, caption: caption)
    failed.errors.full_messages.each { |m| @image.errors.add(:base, m) }
    assign_image_form_hints
    render :new, status: :unprocessable_entity
  end

  def default_kind_for_new
    return :cover if @product.images.cover.none?

    :gallery
  end

  def assign_image_form_hints
    @gallery_used = @product.images.gallery.count
    @cover_exists = @product.images.cover.exists?
    @gallery_remaining = [ Image::MAX_GALLERY_IMAGES - @gallery_used, 0 ].max
    @can_add_image = @product.images.count < Image::MAX_IMAGES_PER_PRODUCT
  end
end
