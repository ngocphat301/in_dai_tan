# frozen_string_literal: true

class AddKindToBlogCategories < ActiveRecord::Migration[8.1]
  class MigrationBlogCategory < ActiveRecord::Base
    self.table_name = "blog_categories"
  end

  def up
    add_column :blog_categories, :kind, :string
    add_index :blog_categories, :kind

    MigrationBlogCategory.reset_column_information
    { "news" => "news", "project" => "project", "service" => "service" }.each do |slug, kind|
      MigrationBlogCategory.where(slug: slug).update_all(kind: kind)
    end
    MigrationBlogCategory.where(kind: nil).update_all(kind: "news")

    change_column_null :blog_categories, :kind, false
    change_column_default :blog_categories, :kind, from: nil, to: "news"

    unless MigrationBlogCategory.exists?(slug: "san-pham")
      MigrationBlogCategory.create!(
        name: "Sản phẩm",
        slug: "san-pham",
        position: 3,
        kind: "product"
      )
    end
  end

  def down
    remove_index :blog_categories, :kind
    remove_column :blog_categories, :kind
  end
end
