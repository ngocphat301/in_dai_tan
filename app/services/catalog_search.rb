# frozen_string_literal: true

# Tìm kiếm full-text trên PostgreSQL (pg_search: tsearch + trigram).
class CatalogSearch
  class << self
    def products(query, product_category_id: nil)
      q = query.to_s.strip
      return Product.none if q.blank?

      rel = Product.where(published: true).merge(
        Product.by_catalog_query(q).or(Product.accent_insensitive_catalog_match(q))
      )
      rel = rel.where(product_category_id: product_category_id) if product_category_id.present?
      rel = order_products_for_search(rel, q)
      rel.includes(:product_category, { images: { file_attachment: :blob } })
         .limit(100)
    end

    # post_scope: "all" | "no_project" | "project"
    def posts(query, category: nil, post_scope: "all")
      q = query.to_s.strip
      return BlogPost.none if q.blank?

      rel = BlogPost.published_now.merge(
        BlogPost.by_catalog_query(q).or(BlogPost.accent_insensitive_catalog_match(q))
      )
      rel = rel.where(category: category) if category.present? && BlogPost.categories.key?(category.to_s)
      rel = apply_post_kind_scope(rel, post_scope)
      rel = order_blog_posts_for_search(rel, q)
      rel.includes({ avatar_attachment: :blob })
         .limit(100)
    end

    def order_blog_posts_for_search(rel, query)
      qq = query.to_s.strip.downcase
      return rel.reorder("blog_posts.published_at DESC NULLS LAST") if qq.blank?

      pat = "%#{ActiveRecord::Base.sanitize_sql_like(qq)}%"
      fragment = ActiveRecord::Base.sanitize_sql_array([
        <<~SQL.squish,
          CASE
            WHEN unaccent(lower(blog_posts.title)) ILIKE unaccent(lower(?::text)) THEN 0
            WHEN unaccent(lower(COALESCE(blog_posts.excerpt, ''))) ILIKE unaccent(lower(?::text))
              OR unaccent(lower(COALESCE(blog_posts.meta_title, ''))) ILIKE unaccent(lower(?::text))
              OR unaccent(lower(COALESCE(blog_posts.meta_description, ''))) ILIKE unaccent(lower(?::text))
            THEN 1
            ELSE 2
          END ASC,
          blog_posts.published_at DESC NULLS LAST
        SQL
        pat, pat, pat, pat
      ])
      rel.reorder(Arel.sql(fragment))
    end

    def order_products_for_search(rel, query)
      qq = query.to_s.strip.downcase
      return rel.reorder("products.created_at DESC") if qq.blank?

      pat = "%#{ActiveRecord::Base.sanitize_sql_like(qq)}%"
      fragment = ActiveRecord::Base.sanitize_sql_array([
        <<~SQL.squish,
          CASE
            WHEN unaccent(lower(products.name)) ILIKE unaccent(lower(?::text)) THEN 0
            WHEN unaccent(lower(COALESCE(products.description, ''))) ILIKE unaccent(lower(?::text)) THEN 1
            ELSE 2
          END ASC,
          products.created_at DESC
        SQL
        pat, pat
      ])
      rel.reorder(Arel.sql(fragment))
    end

    def apply_post_kind_scope(rel, post_scope)
      case post_scope.to_s
      when "no_project"
        rel.where.not(category: :project)
      when "project"
        rel.where(category: :project)
      else
        rel
      end
    end
  end
end
