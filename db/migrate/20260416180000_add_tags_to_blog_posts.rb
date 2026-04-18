# frozen_string_literal: true

class AddTagsToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_posts, :tags, :string, array: true, default: [], null: false
  end
end
