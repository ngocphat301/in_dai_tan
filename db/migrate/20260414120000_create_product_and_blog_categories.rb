# frozen_string_literal: true

class CreateProductAndBlogCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :product_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :product_categories, :slug, unique: true

    create_table :blog_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :position, default: 0, null: false
      t.timestamps
    end
    add_index :blog_categories, :slug, unique: true
  end
end
