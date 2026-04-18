class RenameProductPriceCentsToPriceVnd < ActiveRecord::Migration[8.1]
  def change
    return unless table_exists?(:products)

    if column_exists?(:products, :price_cents) && !column_exists?(:products, :price_vnd)
      rename_column :products, :price_cents, :price_vnd
    end
  end
end
