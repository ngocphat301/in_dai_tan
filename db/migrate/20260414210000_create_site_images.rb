# frozen_string_literal: true

class CreateSiteImages < ActiveRecord::Migration[8.1]
  def change
    create_table :site_images do |t|
      t.string :category, null: false, default: "banner"
      t.integer :position, default: 0, null: false
      t.boolean :published, default: true, null: false
      t.string :link_url
      t.string :alt_text

      t.timestamps
    end

    add_index :site_images, :category
    add_index :site_images, %i[category position]
  end
end
