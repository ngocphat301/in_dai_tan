# frozen_string_literal: true

class SearchesController < ApplicationController
  POST_SEARCH_SCOPES = %w[all no_project project].freeze

  def index
    @q = params[:q].to_s.strip
    @kind = params[:kind].presence_in(%w[product post]) || "product"
    @post_scope = params[:post_scope].presence_in(POST_SEARCH_SCOPES) || "all"

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
      @posts = CatalogSearch.posts(@q, post_scope: @post_scope)
      @products = Product.none
    end
    @breadcrumbs = [ crumb_root, crumb_current("Tìm kiếm") ]
  end
end
