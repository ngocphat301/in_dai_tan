# frozen_string_literal: true

class SearchesController < ApplicationController
  def index
    @q = params[:q].to_s.strip
    @kind = params[:kind].presence_in(%w[product post]) || "post"

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
