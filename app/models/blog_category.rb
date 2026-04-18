class BlogCategory < ApplicationRecord
  has_many :blog_posts, dependent: :restrict_with_error, inverse_of: :blog_category

  enum :kind, {
    news: "news",
    project: "project",
    service: "service",
    product: "product",
    ads: "ads",
    factory_scale: "factory_scale"
  }, default: :news

  validates :name, presence: true
  validates :slug, presence: true,
                    uniqueness: { case_sensitive: true },
                    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "chỉ dùng chữ thường, số và gạch ngang" }

  before_validation :assign_slug, if: -> { name.present? && slug.blank? }

  scope :ordered, -> { order(:position, :name) }

  private

  def assign_slug
    self.slug = name.to_s.parameterize
  end
end
