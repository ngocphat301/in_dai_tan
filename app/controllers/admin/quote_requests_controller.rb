# frozen_string_literal: true

class Admin::QuoteRequestsController < Admin::BaseController
  before_action :set_quote_request, only: %i[edit update toggle_staff_received]

  def index
    scope = QuoteRequest.includes(:product, :blog_post, :product_category, :assigned_to)
    if params[:request_type].present? && QuoteRequest.request_types.values.include?(params[:request_type])
      scope = scope.where(request_type: params[:request_type])
    end
    if params[:product_category_id].present?
      scope = scope.where(product_category_id: params[:product_category_id])
    end
    if params[:staff_received].in?(%w[true false])
      scope = scope.where(staff_received: params[:staff_received] == "true")
    end
    if params[:purchase_status].present? && QuoteRequest.purchase_statuses.key?(params[:purchase_status])
      scope = scope.where(purchase_status: params[:purchase_status])
    end
    if (p = admin_like_pattern)
      scope = scope.where(
        <<~SQL.squish,
          quote_requests.customer_name ILIKE :q
          OR quote_requests.phone ILIKE :q
          OR COALESCE(quote_requests.body, '') ILIKE :q
        SQL
        q: p
      )
    end
    scope = apply_admin_order(
      scope,
      allowed: %w[created_at updated_at customer_name phone purchase_status staff_received],
      default: "updated_at"
    )
    pag = admin_paginate(scope)
    @quote_requests = pag[:records]
    @product_categories = ProductCategory.ordered
    @admin_page = pag[:page]
    @admin_total_pages = pag[:total_pages]
    @admin_total_count = pag[:total_count]
  end

  def edit
  end

  def update
    if @quote_request.update(admin_quote_params)
      redirect_to admin_quote_requests_path, notice: "Đã cập nhật yêu cầu báo giá."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_staff_received
    @quote_request.update!(staff_received: !@quote_request.staff_received)
    redirect_back fallback_location: admin_quote_requests_path,
                  notice: (@quote_request.staff_received? ? "Đã đánh dấu tiếp nhận." : "Đã đánh dấu chưa tiếp nhận.")
  end

  private

  def set_quote_request
    @quote_request = QuoteRequest.find(params[:id])
  end

  def admin_quote_params
    params.require(:quote_request).permit(:purchase_status, :assigned_to_id)
  end
end