class BlogPost < ApplicationRecord
  include ::PgSearch::Model
  include AccentInsensitiveCatalogMatch

  pg_search_scope :by_catalog_query,
    against: %i[title excerpt meta_title meta_description],
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
    order_within_rank: "blog_posts.published_at DESC NULLS LAST"

  belongs_to :user
  belongs_to :blog_category, inverse_of: :blog_posts

  has_one :linked_product_category, class_name: "ProductCategory", foreign_key: :blog_post_id,
                                    dependent: :nullify, inverse_of: :blog_post
  has_many :quote_requests, dependent: :nullify, inverse_of: :blog_post

  has_one_attached :avatar
  has_rich_text :body

  attribute :status, :string, default: "hidden"

  enum :status, { publish: "publish", hidden: "hidden" }, default: :hidden

  validates :title, presence: true
  validates :slug, presence: true,
                    uniqueness: { case_sensitive: true },
                    format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "chỉ dùng chữ thường, số và dấu gạch ngang" }
  validate :acceptable_avatar, if: -> { avatar.attached? }

  before_validation :assign_slug, if: -> { title.present? && slug.blank? }

  before_save :sync_publish_state

  scope :accent_insensitive_catalog_match, lambda { |query|
    accent_insensitive_columns_match(query, %w[title excerpt meta_title meta_description])
  }

  scope :ordered, -> { order(updated_at: :desc) }
  scope :published_now, lambda {
    where(status: :publish).where.not(published_at: nil).where(published_at: ..Time.current).order(published_at: :desc)
  }

  def self.parse_tag_list(str)
    str.to_s.split(/[,;|]/).map { |t| t.strip.downcase.presence }.compact.uniq
  end

  def tag_list
    Array(tags).join(", ")
  end

  def tag_list=(str)
    self.tags = self.class.parse_tag_list(str)
  end

  # Bài loại «Sản phẩm» có tag trùng với bài dịch vụ hiện tại (dùng tag_list khi so khớp).
  def normalized_tag_tokens
    Array(tags).map { |t| t.to_s.strip.downcase }.reject(&:blank?).uniq
  end

  def related_product_blog_posts(limit: 6)
    my = normalized_tag_tokens
    return self.class.none if my.empty?

    pid = BlogCategory.find_by(kind: :product)&.id
    return self.class.none unless pid

    self.class.published_now
      .where(blog_category_id: pid)
      .where.not(id: id)
      .order(published_at: :desc)
      .limit(120)
      .select { |p| (p.normalized_tag_tokens & my).any? }
      .first(limit)
  end

  # Bài đã xuất bản (trừ loại dự án): ưu tiên trùng tag, không có tag thì cùng danh mục blog.
  def related_blog_posts(limit: 6)
    project_scope = BlogCategory.where(kind: :project).select(:id)
    base = self.class.published_now
      .includes(:blog_category, { avatar_attachment: :blob })
      .where.not(id: id)
      .where.not(blog_category_id: project_scope)
      .order(published_at: :desc)

    my = normalized_tag_tokens
    if my.any?
      tagged = base.limit(100).select { |p| (p.normalized_tag_tokens & my).any? }.first(limit)
      return tagged if tagged.any?
    end

    base.where(blog_category_id: blog_category_id).limit(limit).to_a
  end

  # Bài dự án liên quan: cùng loại dự án, ưu tiên tag.
  def related_project_posts(limit: 6)
    project_scope = BlogCategory.where(kind: :project).select(:id)
    base = self.class.published_now
      .includes(:blog_category, { avatar_attachment: :blob })
      .where.not(id: id)
      .where(blog_category_id: project_scope)
      .order(published_at: :desc)

    my = normalized_tag_tokens
    if my.any?
      tagged = base.limit(100).select { |p| (p.normalized_tag_tokens & my).any? }.first(limit)
      return tagged if tagged.any?
    end

    base.where(blog_category_id: blog_category_id).limit(limit).to_a
  end

  # Tiêu đề, mô tả ngắn, meta (nội dung rich text xem trên trang bài)
  scope :search_text, lambda { |query|
    q = query.to_s.strip
    return all if q.blank?

    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
    where(
      <<~SQL.squish,
        blog_posts.title ILIKE :p
        OR COALESCE(blog_posts.excerpt, '') ILIKE :p
        OR COALESCE(blog_posts.meta_title, '') ILIKE :p
        OR COALESCE(blog_posts.meta_description, '') ILIKE :p
      SQL
      p: pattern
    )
  }

  def self.status_options_for_select
    [
      [ "Xuất bản (hiển thị công khai)", "publish" ],
      [ "Ẩn", "hidden" ]
    ]
  end

  def category_label
    blog_category&.name
  end

  def status_label
    case status
    when "publish" then "Xuất bản"
    when "hidden" then "Ẩn"
    else status
    end
  end

  def published_for_public?
    publish? && published_at.present? && published_at <= Time.current
  end

  def search_body_plain
    return "" unless body.present?

    body.to_plain_text.to_s.truncate(50_000)
  rescue StandardError
    ""
  end

  private

  def acceptable_avatar
    type = avatar.blob&.content_type
    return if type.blank?

    return if type.in?(%w[image/jpeg image/png image/webp image/gif])

    errors.add(:avatar, "chỉ chấp nhận JPEG, PNG, WebP hoặc GIF")
  end

  def sync_publish_state
    if publish?
      self.published_at ||= Time.current
    else
      self.published_at = nil
    end
  end

  def assign_slug
    base = title.to_s.parameterize
    candidate = base
    suffix = 1
    while BlogPost.where.not(id: id).exists?(slug: candidate)
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end
    self.slug = candidate
  end
end
