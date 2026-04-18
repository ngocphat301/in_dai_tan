# frozen_string_literal: true

class AddPricingPromoToProducts < ActiveRecord::Migration[8.1]
  def change
    rename_column :products, :price_vnd, :sale_price_vnd
    add_column :products, :original_price_vnd, :integer, null: false, default: 0
    add_column :products, :promo_starts_at, :datetime
    add_column :products, :promo_ends_at, :datetime
  end
end
