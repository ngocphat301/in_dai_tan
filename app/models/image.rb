class Image < ApplicationRecord
  MAX_IMAGES_PER_PRODUCT = 5
  MAX_GALLERY_IMAGES = 4

  belongs_to :product, inverse_of: :images

  has_one_attached :file

  attribute :kind, :string, default: "gallery"

  enum :kind, { gallery: "gallery", cover: "cover" }, default: :gallery

  before_validation :demote_other_covers, if: :cover?

  validate :file_must_be_attached_for_new_records
  validate :gallery_quota
  validate :product_image_quota, on: :create

  scope :covers, -> { where(kind: "cover") }
  scope :galleries, -> { where(kind: "gallery") }

  private

  def demote_other_covers
    return unless product&.persisted?

    scope = product.images.cover
    scope = scope.where.not(id: id) if persisted?
    scope.update_all(kind: "gallery")
  end

  def gallery_quota
    return unless gallery? && product&.persisted?

    others = product.images.where(kind: "gallery")
    others = others.where.not(id: id) if persisted?
    return if others.count < MAX_GALLERY_IMAGES

    errors.add(:kind, "đã đủ #{MAX_GALLERY_IMAGES} ảnh đi kèm (chọn ảnh đại diện hoặc xóa bớt ảnh phụ)")
  end

  def product_image_quota
    return unless product&.persisted?

    errors.add(:base, "Mỗi sản phẩm tối đa #{MAX_IMAGES_PER_PRODUCT} ảnh (1 đại diện + 4 đi kèm)") if product.images.count >= MAX_IMAGES_PER_PRODUCT
  end

  def file_must_be_attached_for_new_records
    return unless new_record?

    errors.add(:file, "cần có tệp ảnh") unless file.attached?
  end
end
