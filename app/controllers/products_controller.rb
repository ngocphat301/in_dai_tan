class ProductsController < ApplicationController
  include PaginatedCatalog

  def index
    scope = BlogPost.published_now
      .where(category: :product)
      .includes({ avatar_attachment: :blob })

    pag = paginate_scope(scope)
    @product_blog_posts = pag[:records]
    @page = pag[:page]
    @per_page = pag[:per]
    @total_pages = pag[:total_pages]
    @total_count = pag[:total_count]
    @prev_path = products_path(page: @page - 1) if @page > 1
    @next_path = products_path(page: @page + 1) if @page < @total_pages
    @breadcrumbs = [ crumb_root, crumb_current("Sản phẩm") ]
    @seo = {
      title: "Sản phẩm",
      description: seo_truncate_description(
        "Bài giới thiệu bao bì và giải pháp in — danh mục blog loại Sản phẩm tại In Tân Đại."
      ),
      canonical: seo_current_canonical_url(request),
      og_type: "website",
      og_image: seo_default_og_image_url(request)
    }
    @seo_json_ld_extra = seo_blog_post_item_list_json_ld(
      @product_blog_posts,
      request,
      name: "Sản phẩm",
      description: @seo[:description]
    )
  end

  def show
    @product = Product.published_list.includes(:product_category, images: { file_attachment: :blob }).find(params[:id])
    @quote_return_to = "product"
    @quote_request.product_category_id = @product.product_category_id if @quote_request.product_category_id.blank?
    @breadcrumbs = [
      crumb_root,
      { label: "Sản phẩm", path: products_path },
      crumb_current(@product.name)
    ]

    desc = @product.description.to_s.strip.presence || "#{@product.name} — báo giá in ấn tại In Tân Đại."
    canonical = seo_current_canonical_url(request)
    origin = seo_site_origin(request)

    @seo = {
      title: @product.name,
      description: seo_truncate_description(desc),
      canonical: canonical,
      og_type: "product",
      og_image: seo_product_og_image_url(@product, request)
    }
    product_ld = {
      "@type" => "Product",
      "name" => @product.name,
      "description" => seo_truncate_description(desc, 500),
      "image" => product_gallery_items(@product).map do |item|
        image_url = item[:url].to_s
        image_url.start_with?("http://", "https://") ? image_url : "#{origin}#{image_url}"
      end,
      "offers" => {
        "@type" => "Offer",
        "priceCurrency" => "VND",
        "price" => @product.sale_price_vnd.to_i,
        "availability" => "https://schema.org/InStock",
        "url" => canonical
      }
    }
    trail_ld = seo_breadcrumb_list_json_ld(@breadcrumbs, request, page_url: canonical)
    @seo_json_ld_extra = [ product_ld, trail_ld ].compact
  end
end
