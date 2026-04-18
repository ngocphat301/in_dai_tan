# frozen_string_literal: true

class AddBlogPostToProductCategories < ActiveRecord::Migration[8.1]
  def change
    add_reference :product_categories, :blog_post, null: true,
                  foreign_key: { on_delete: :nullify },
                  index: { unique: true }
  end
end
