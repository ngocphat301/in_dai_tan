# frozen_string_literal: true

class AddKindToImages < ActiveRecord::Migration[8.1]
  def up
    add_column :images, :kind, :string, null: false, default: "gallery"

    execute <<-SQL.squish
      UPDATE images AS i
      SET kind = 'cover'
      FROM (
        SELECT DISTINCT ON (product_id) id
        FROM images
        ORDER BY product_id, "position", id
      ) AS first_per_product
      WHERE i.id = first_per_product.id
    SQL
  end

  def down
    remove_column :images, :kind
  end
end
