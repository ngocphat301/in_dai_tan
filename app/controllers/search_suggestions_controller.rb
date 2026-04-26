# frozen_string_literal: true

class SearchSuggestionsController < ApplicationController
  def index
    q = params[:q].to_s.strip
    items = suggestions_for(q)
    render json: { suggestions: items }
  end

  private

  def suggestions_for(q)
    return [] if q.length < 2

    kind = params[:kind].presence_in(%w[product post]) || "post"
    prefix = "#{ActiveRecord::Base.sanitize_sql_like(q.strip.downcase)}%"
    seen = {}
    out = []

    if kind == "post"
      rel = BlogPost.published_now.where(
        [ "unaccent(lower(blog_posts.title)) ILIKE unaccent(lower(?::text))", prefix ]
      )
      rel = CatalogSearch.apply_post_kind_scope(rel, "all")
      rel.order(:title).limit(12).each do |b|
        next if seen.key?(b.title)

        seen[b.title] = true
        out << { text: b.title, url: blog_post_path(b.slug) }
      end
    else
      Product.where(published: true).where(
        [ "unaccent(lower(products.name)) ILIKE unaccent(lower(?::text))", prefix ]
      ).order(:name).limit(12).each do |p|
        next if seen.key?(p.name)

        seen[p.name] = true
        out << { text: p.name, url: product_path(p) }
      end
    end

    out
  end
end
