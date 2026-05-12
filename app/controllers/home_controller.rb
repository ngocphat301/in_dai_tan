class HomeController < ApplicationController
  include HomePageData

  def index
    load_home_page_data
    @breadcrumbs = nil
    @seo = {
      title: "Trang chủ",
      description: seo_truncate_description(
        "In Tân Đại — xưởng in offset, hộp giấy, bao bì và ấn phẩm thương mại tại Hà Nội. Báo giá minh bạch, đúng tiến độ."
      ),
      canonical: seo_current_canonical_url(request),
      og_type: "website",
      og_image: seo_default_og_image_url(request)
    }
  end
end
