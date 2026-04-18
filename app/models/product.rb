class Product < ApplicationRecord
  include ::PgSearch::Model
  include AccentInsensitiveCatalogMatch

  pg_search_scope :by_catalog_query,
    against: %i[name description],
    using: {
      tsearch: {
        dictionary: "simple",
        prefix: true
      },
      trigram: {
        threshold: 0.22,
        word_similarity: true
      }
    },
    order_within_rank: "products.created_at DESC"

  belongs_to :product_category, inverse_of: :products

  has_many :images, -> { order(:kind, :position, :id) }, dependent: :destroy, inverse_of: :product
  has_many :quote_requests, dependent: :restrict_with_error, inverse_of: :product

  validates :name, presence: true
  validates :sale_price_vnd, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :original_price_vnd, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :promo_range_valid

  scope :accent_insensitive_catalog_match, lambda { |query|
    accent_insensitive_columns_match(query, %w[name description])
  }

  scope :published_list, -> { where(published: true).order(created_at: :desc) }

  # q: từ khóa tìm trong tên & mô tả (PostgreSQL ILIKE) — dự phòng / gọi trực tiếp
  scope :search_text, lambda { |query|
    q = query.to_s.strip
    return all if q.blank?

    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
    where("products.name ILIKE :p OR COALESCE(products.description, '') ILIKE :p", p: pattern)
  }

  scope :price_from, lambda { |vnd|
    v = vnd.to_i
    v.positive? ? where("products.sale_price_vnd >= ?", v) : all
  }

  scope :price_to, lambda { |vnd|
    v = vnd.to_i
    v.positive? ? where("products.sale_price_vnd <= ?", v) : all
  }

  # Đang trong khung giờ khuyến mãi (hiển thị countdown / nhãn flash).
  def promo_active?
    return false if promo_starts_at.blank? || promo_ends_at.blank?

    now = Time.current
    now >= promo_starts_at && now < promo_ends_at
  end

  def cover_image
    images.cover.first || images.first
  end

  def gallery_images
    images.gallery.order(:position, :id)
  end

  private

  def promo_range_valid
    return if promo_starts_at.blank? && promo_ends_at.blank?
    return errors.add(:promo_ends_at, "cần có cả thời điểm bắt đầu") if promo_starts_at.blank?
    return errors.add(:promo_starts_at, "cần có cả thời điểm kết thúc") if promo_ends_at.blank?

    errors.add(:promo_ends_at, "phải sau thời điểm bắt đầu") if promo_ends_at <= promo_starts_at
  end
end
