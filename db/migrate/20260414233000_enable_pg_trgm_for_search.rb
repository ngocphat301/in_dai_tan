# frozen_string_literal: true

class EnablePgTrgmForSearch < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    add_index :products, :name, opclass: :gin_trgm_ops, using: :gin, name: "index_products_on_name_trgm"
    add_index :blog_posts, :title, opclass: :gin_trgm_ops, using: :gin, name: "index_blog_posts_on_title_trgm"
  end
end
