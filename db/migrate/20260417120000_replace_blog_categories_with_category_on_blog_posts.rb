# frozen_string_literal: true

class ReplaceBlogCategoriesWithCategoryOnBlogPosts < ActiveRecord::Migration[8.1]
  def up
    add_column :blog_posts, :category, :string

    execute <<-SQL.squish
      UPDATE blog_posts AS bp
      SET category = bc.kind
      FROM blog_categories AS bc
      WHERE bp.blog_category_id = bc.id
    SQL

    execute "UPDATE blog_posts SET category = 'news' WHERE category IS NULL"

    change_column_null :blog_posts, :category, false
    change_column_default :blog_posts, :category, from: nil, to: "news"

    add_index :blog_posts, :category

    remove_foreign_key :blog_posts, :blog_categories
    remove_column :blog_posts, :blog_category_id

    drop_table :blog_categories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
