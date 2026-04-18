# frozen_string_literal: true

class CreateAdLeadsAndPopupTitleOnSiteImages < ActiveRecord::Migration[8.1]
  def change
    create_table :ad_leads do |t|
      t.string :phone, null: false
      t.timestamps
    end
    add_index :ad_leads, :created_at

    add_column :site_images, :popup_title, :string
  end
end
