# frozen_string_literal: true

# Trang bài blog «Dịch vụ»: form báo giá gắn bài + danh mục sản phẩm đã liên kết (product_categories.blog_post_id).
module ServiceBlogQuotePrefill
  extend ActiveSupport::Concern

  private

  def prefill_quote_request_for_service_blog
    return unless @blog_post.present? && @blog_post.category_service?
    return unless @quote_request

    pc = @blog_post.linked_product_category
    @quote_request.blog_post_id = @blog_post.id
    @quote_request.product_category_id = pc.id if pc.present? && @quote_request.product_category_id.blank?
  end
end
