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
  end
end
