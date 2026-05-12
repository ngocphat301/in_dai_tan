# frozen_string_literal: true

class SearchesController < ApplicationController
  def index
    @q = params[:q].to_s.strip
    @kind = params[:kind].presence_in(%w[product post]) || "post"
    @seo = {
      title: "Tìm kiếm",
      description: "Kết quả tìm kiếm trên In Tân Đại.",
      canonical: seo_current_canonical_url(request),
      og_type: "website",
      og_image: seo_default_og_image_url(request),
      noindex: true
    }

    if @q.blank?
      @products = Product.none
      @posts = BlogPost.none
      @breadcrumbs = [ crumb_root, crumb_current("Tìm kiếm") ]
      return
    end

    if @kind == "product"
      @products = CatalogSearch.products(@q)
      @posts = BlogPost.none
    else
      @posts = CatalogSearch.posts(@q, post_scope: "all")
      @products = Product.none
    end
    @breadcrumbs = [ crumb_root, crumb_current("Tìm kiếm") ]
  end
end
