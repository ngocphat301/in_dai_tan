class Admin::BaseController < ApplicationController
  include AdminPaginatable

  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_admin_sort_defaults

  layout "admin"

  private

  # Hiển thị trạng thái sort trên thead khi chưa có ?sort= (khớp apply_admin_order default).
  def set_admin_sort_defaults
    @admin_default_sort = "updated_at"
    @admin_default_sort_dir = "desc"
  end

  # ILIKE "%…%" cho ô tìm (?q=) — dùng trong các action index.
  def admin_like_pattern
    q = params[:q].to_s.strip
    return if q.blank?

    "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
  end

  def require_admin
    redirect_to root_path, alert: "Bạn không có quyền truy cập khu vực quản trị." unless current_user.admin?
  end
end
