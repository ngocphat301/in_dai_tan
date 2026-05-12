class PagesController < ApplicationController
  def about
    @quote_return_to = "about"
    @breadcrumbs = [ crumb_root, crumb_current("Giới thiệu") ]
    @seo = {
      title: "Giới thiệu",
      description: seo_truncate_description(
        "Giới thiệu Công ty Bao bì In Tân Đại — triết lý kinh doanh, năng lực sản xuất, công nghệ in ấn và đội ngũ."
      ),
      canonical: seo_current_canonical_url(request),
      og_type: "website",
      og_image: seo_default_og_image_url(request)
    }
  end

  def contact
    @quote_return_to = "contact"
    @breadcrumbs = [ crumb_root, crumb_current("Liên hệ") ]
    @seo = {
      title: "Liên hệ",
      description: seo_truncate_description(
        "Liên hệ In Tân Đại — địa chỉ xưởng Triều Khúc, văn phòng Thanh Liệt, hotline 0898 040 222, email inantandai@gmail.com."
      ),
      canonical: seo_current_canonical_url(request),
      og_type: "website",
      og_image: seo_default_og_image_url(request)
    }
  end
end
