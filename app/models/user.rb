class User < ApplicationRecord
  has_many :blog_posts, dependent: :destroy
  has_many :assigned_quote_requests, class_name: "QuoteRequest", foreign_key: :assigned_to_id,
                                       inverse_of: :assigned_to, dependent: :nullify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Rails 8: string enums need an explicit attribute type if the column is not yet in the schema cache.
  attribute :role, :string, default: "member"

  enum :role, { member: "member", admin: "admin" }, default: :member

  scope :quote_assignable, -> { order(:email) }

  # Hiển thị trong form báo giá / admin
  def quote_display_name
    email.to_s
  end

  validate :cannot_demote_last_admin, on: :update

  before_destroy :cannot_delete_last_admin

  private

  def cannot_demote_last_admin
    return unless role_changed?
    return unless role_was == "admin" && member?
    return if User.admin.where.not(id: id).exists?

    errors.add(:role, "phải còn ít nhất một tài khoản admin")
  end

  def cannot_delete_last_admin
    return unless admin?
    return if User.admin.where.not(id: id).exists?

    errors.add(:base, "Không thể xóa admin cuối cùng")
    throw :abort
  end
end
