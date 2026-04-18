class ProductCategory < ApplicationRecord
  belongs_to :blog_post, optional: true, inverse_of: :linked_product_category

  has_many :products, dependent: :restrict_with_error, inverse_of: :product_category
  has_many :quote_requests, dependent: :restrict_with_error, inverse_of: :product_category

  validates :name, presence: true
  validates :slug, presence: true,
                    uniqueness: { case_sensitive: true },
                    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "chỉ dùng chữ thường, số và gạch ngang" }

  before_validation :assign_slug, if: -> { name.present? && slug.blank? }

  validate :blog_post_belongs_to_service_category, if: -> { blog_post.present? }

  scope :ordered, -> { order(:position, :name) }

  private

  def blog_post_belongs_to_service_category
    return if blog_post.blog_category&.slug == "service"

    errors.add(:blog_post_id, "chỉ gắn bài thuộc danh mục blog «Dịch vụ»")
  end

  def assign_slug
    self.slug = name.to_s.parameterize
  end
end
