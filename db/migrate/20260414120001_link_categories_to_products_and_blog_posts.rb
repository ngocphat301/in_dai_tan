# frozen_string_literal: true

class LinkCategoriesToProductsAndBlogPosts < ActiveRecord::Migration[8.1]
  def up
    say_with_time "inserting blog_categories" do
      execute <<-SQL.squish
        INSERT INTO blog_categories (name, slug, position, created_at, updated_at) VALUES
        ('Tin tức', 'news', 0, NOW(), NOW()),
        ('Dự án', 'project', 1, NOW(), NOW()),
        ('Dịch vụ', 'service', 2, NOW(), NOW())
      SQL
    end

    say_with_time "inserting product_categories" do
      execute <<-SQL.squish
        INSERT INTO product_categories (name, slug, position, created_at, updated_at) VALUES
        ('Chung', 'chung', 0, NOW(), NOW()),
        ('Ấn phẩm văn phòng', 'an-pham-van-phong', 1, NOW(), NOW()),
        ('Ấn phẩm quảng cáo', 'an-pham-quang-cao', 2, NOW(), NOW()),
        ('Bao bì & hộp', 'bao-bi-hop', 3, NOW(), NOW())
      SQL
    end

    add_reference :products, :product_category, null: true, foreign_key: true
    add_reference :blog_posts, :blog_category, null: true, foreign_key: true

    default_pc = select_value("SELECT id FROM product_categories WHERE slug = 'chung' LIMIT 1")
    execute "UPDATE products SET product_category_id = #{connection.quote(default_pc)}" if default_pc

    say_with_time "backfill blog_posts.blog_category_id from category column" do
      execute <<-SQL.squish
        UPDATE blog_posts
        SET blog_category_id = blog_categories.id
        FROM blog_categories
        WHERE blog_posts.category = blog_categories.slug
      SQL
    end

    orphan = select_value("SELECT COUNT(*) FROM blog_posts WHERE blog_category_id IS NULL").to_i
    if orphan.positive?
      fallback = select_value("SELECT id FROM blog_categories WHERE slug = 'news' LIMIT 1")
      execute "UPDATE blog_posts SET blog_category_id = #{connection.quote(fallback)} WHERE blog_category_id IS NULL"
    end

    change_column_null :products, :product_category_id, false
    change_column_null :blog_posts, :blog_category_id, false

    remove_index :blog_posts, :category if index_exists?(:blog_posts, :category)
    remove_column :blog_posts, :category, :string
  end

  def down
    add_column :blog_posts, :category, :string, default: "news", null: false

    execute <<-SQL.squish
      UPDATE blog_posts
      SET category = blog_categories.slug
      FROM blog_categories
      WHERE blog_posts.blog_category_id = blog_categories.id
    SQL

    add_index :blog_posts, :category

    change_column_null :products, :product_category_id, true
    change_column_null :blog_posts, :blog_category_id, true

    remove_reference :blog_posts, :blog_category, foreign_key: true
    remove_reference :products, :product_category, foreign_key: true

    execute "DELETE FROM blog_categories"
    execute "DELETE FROM product_categories"
  end
end
