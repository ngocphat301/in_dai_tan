class HomeController < ApplicationController
  include HomePageData

  def index
    load_home_page_data
    @breadcrumbs = nil
    @seo = {
      title: "Trang chủ",
      document_title: "In Ấn Tân Đại: Dịch vụ In hộp giấy, túi giấy, hộp carton chất lượng cao",
      description: seo_truncate_description(
        "Xưởng in Tân Đại nhận thiết kế và sản xuất hộp giấy, túi giấy, hộp carton sóng chất lượng cao tại Hà Nội và miền Bắc, báo giá nhanh, giao hàng đúng hẹn."
      ),
      canonical: seo_current_canonical_url(request),
      og_type: "website",
      og_image: seo_default_og_image_url(request)
    }
  end
end
