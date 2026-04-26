# frozen_string_literal: true

# Khóa cache dùng chung cho fragment dữ liệu layout public (header, popup).
module LayoutCache
  HEADER_CATEGORIES_KEY = "layout/v1/header_product_categories"
  ADS_POPUP_KEY = "layout/v1/ads_popup_post"

  module_function

  def expire_header_categories!
    Rails.cache.delete(HEADER_CATEGORIES_KEY)
  end

  def expire_ads_popup!
    Rails.cache.delete(ADS_POPUP_KEY)
  end
end
