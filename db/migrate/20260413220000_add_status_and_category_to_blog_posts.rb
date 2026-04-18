# frozen_string_literal: true

class AddStatusAndCategoryToBlogPosts < ActiveRecord::Migration[8.1]
  def up
    add_column :blog_posts, :status, :string, null: false, default: "hidden"
    add_column :blog_posts, :category, :string, null: false, default: "news"

    execute <<-SQL.squish
      UPDATE blog_posts
      SET status = CASE WHEN published = TRUE AND published_at IS NOT NULL THEN 'publish' ELSE 'hidden' END
    SQL

    remove_index :blog_posts, :published, if_exists: true
    remove_column :blog_posts, :published, :boolean

    add_index :blog_posts, :status
    add_index :blog_posts, :category
  end

  def down
    add_column :blog_posts, :published, :boolean, null: false, default: false

    execute <<-SQL.squish
      UPDATE blog_posts SET published = TRUE WHERE status = 'publish'
    SQL

    remove_index :blog_posts, :category
    remove_index :blog_posts, :status
    remove_column :blog_posts, :category
    remove_column :blog_posts, :status

    add_index :blog_posts, :published
  end
end
