# frozen_string_literal: true

class QuoteRequest < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :product_category, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :blog_post, optional: true

  # Không dùng key :product (trùng association `belongs_to :product`).
  enum :request_type, {
    from_product_page: "product",
    from_ads_popup: "ads"
  }, default: :from_product_page, prefix: true

  enum :purchase_status, {
    pending: "pending",
    purchased: "purchased",
    not_purchased: "not_purchased"
  }, default: :pending

  validates :customer_name, presence: true, length: { maximum: 120 }
  validates :phone, presence: true, length: { maximum: 40 }
  validates :phone, format: { with: /\A[\d+\s().-]{8,40}\z/, message: "không hợp lệ" }
  validates :body, presence: true, length: { maximum: 10_000 }

  validate :product_category_must_exist, if: -> { request_type_from_product_page? && product_category_id.present? }
  validate :blog_post_must_be_valid_printing_service, if: -> { request_type_from_product_page? && blog_post_id.present? }
  validate :assigned_to_must_be_assignable, if: -> { assigned_to_id.present? }

  before_validation :sync_quote_references
  before_validation :normalize_assigned_to_id

  scope :recent, -> { order(created_at: :desc) }

  def self.purchase_status_options_for_admin
    [
      [ "Chưa xác định", "pending" ],
      [ "Đã mua", "purchased" ],
      [ "Không mua", "not_purchased" ]
    ]
  end

  def staff_received_label
    staff_received? ? "Đã tiếp nhận" : "Chưa tiếp nhận"
  end

  def purchase_status_label
    case purchase_status
    when "purchased" then "Đã mua"
    when "not_purchased" then "Không mua"
    else "Chưa xác định"
    end
  end

  def request_type_label
    request_type_from_ads_popup? ? "Popup quảng cáo" : "Sản phẩm"
  end

  def quote_subject_label
    product_category&.name.presence || blog_post&.title.presence || product&.name
  end

  private

  def sync_quote_references
    if product_id.present?
      p = Product.find_by(id: product_id)
      self.product_category_id = p&.product_category_id
    elsif product_category_id.present?
      self.product_id = nil
      self.blog_post_id = nil
    elsif blog_post_id.present?
      self.product_id = nil
      post = BlogPost.find_by(id: blog_post_id)
      if post
        pc = ProductCategory.find_by(blog_post_id: post.id)
        self.product_category_id = pc&.id
      end
    end
  end

  def product_category_must_exist
    return if ProductCategory.exists?(id: product_category_id)

    errors.add(:product_category_id, "không hợp lệ")
  end

  def blog_post_must_be_valid_printing_service
    post = BlogPost.find_by(id: blog_post_id)
    if post.nil?
      errors.add(:blog_post_id, "không tồn tại")
    elsif !post.published_for_public?
      errors.add(:blog_post_id, "không còn hiển thị")
    elsif !post.category_service?
      errors.add(:blog_post_id, "phải là bài dịch vụ in")
    end
  end

  def normalize_assigned_to_id
    self.assigned_to_id = nil if assigned_to_id.blank? || assigned_to_id.to_i <= 0
  end

  def assigned_to_must_be_assignable
    return if User.quote_assignable.exists?(assigned_to_id)

    errors.add(:assigned_to_id, "không hợp lệ")
  end
end
